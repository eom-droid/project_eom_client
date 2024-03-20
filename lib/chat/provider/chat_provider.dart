import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/provider/chat_room_provider.dart';
import 'package:client/chat/repository/chat_repository.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:uuid/uuid.dart';

final chatProvider =
    StateNotifierProvider.family<ChatStateNotifier, ChatPagination, String>(
        (ref, roomId) {
  final chatRepository = ref.read(chatRepositoryProvider(roomId));
  final me = ref.read(userProvider) as UserModel;

  return ChatManageStateNotifier(
    repository: chatRepository,
    me: me,
    ref: ref,
  ).getChatNotifier(
    roomId: roomId,
  );
});

class ChatManageStateNotifier
    extends StateNotifier<Map<String, ChatStateNotifier>> {
  final ChatRepository repository;
  final StateNotifierProviderRef ref;
  final UserModel me;
  ChatManageStateNotifier({
    required this.repository,
    required this.ref,
    required this.me,
  }) : super({});

  ChatStateNotifier getChatNotifier({
    required String roomId,
  }) {
    // 1. state에 id가 존재하는지 확인
    // 2. 존재한다면 해당 state를 리턴
    // 3. 존재하지 않는다면 새로운 state를 생성하여 리턴 -> 이때 paginating 같이 진행됨

    if (state.containsKey(roomId)) {
      return state[roomId]!;
    }

    // 채팅방에 대한 정보에서 해당 방에 존재하는 유저들이 마지막으로 읽은 메시지를 가져온다.
    final chatRoomState =
        ref.read(chatRoomProvider.notifier).getChatRoomInfo(roomId);
    Map<String, String?> memberLastReadChatMap = {};

    for (var element in chatRoomState!.members) {
      memberLastReadChatMap[element.id] = element.lastReadChatId;
    }

    state[roomId] = ChatStateNotifier(
      repository: repository,
      roomId: roomId,
      ref: ref,
      me: me,
      memberLastReadChatMap: memberLastReadChatMap,
    );

    return state[roomId]!;
  }
}

class ChatPagination {
  final CursorPaginationBase currentState;
  // 한번도 읽지 않았다면 null
  final Map<String, String?> memberLastReadChatMap;
  final String roomId;

  ChatPagination({
    required this.currentState,
    required this.memberLastReadChatMap,
    required this.roomId,
  });

  ChatPagination copyWith({
    CursorPaginationBase? state,
    Map<String, String?>? memberLastReadChatMap,
    String? roomId,
  }) {
    return ChatPagination(
      currentState: state ?? currentState,
      memberLastReadChatMap:
          memberLastReadChatMap ?? this.memberLastReadChatMap,
      roomId: roomId ?? this.roomId,
    );
  }
}

class ChatStateNotifier extends StateNotifier<ChatPagination> {
  final ChatRepository repository;
  final StateNotifierProviderRef ref;
  final String roomId;
  final String randomKey = const Uuid().v4();
  final UserModel me;
  bool initialized = false;

  ChatStateNotifier({
    required this.repository,
    required this.roomId,
    required this.ref,
    required this.me,
    required Map<String, String?> memberLastReadChatMap,
  }) : super(ChatPagination(
          currentState: CursorPaginationLoading(),
          memberLastReadChatMap: memberLastReadChatMap,
          roomId: roomId,
        )) {
    init();
  }

  init() {
    repository.socketOnAll();
    ref
        .read(chatRepositoryProvider(roomId))
        .chatResponse
        .stream
        .listen(_listener);
  }

  setFirstChat(ChatModel? chat) {
    final pState = state.copyWith(
        state: CursorPagination<ChatModel>(
      meta: CursorPaginationMeta(
        hasMore: false,
        count: 0,
      ),
      data: chat != null ? [chat] : [],
    ));

    state = pState;
  }

  _listener(ChatResponseModel resp) async {
    try {
      final resObj = resp.data;
      final statusCode = resObj['status'];
      // * 401 에러가 발생하면 로그인 페이지로 이동
      // 분기마다 401 statusCode에 대한 처리가 다름

      switch (resp.state) {
        case ChatResponseState.getMessageRes:
          _getMessageResProccess(
            statusCode: statusCode,
            resObj: resObj,
          );
          break;
        case ChatResponseState.paginateMessageRes:
          _paginateMessageResProccess(
            statusCode: statusCode,
            resObj: resObj,
          );
          break;
        case ChatResponseState.sendMessageRes:
          await _sendMessageResProccess(
            resObj: resObj,
            statusCode: statusCode,
          );
          break;

        case ChatResponseState.enterRoomRes:
          await _enterRoomResProccess(
            resObj: resObj,
            statusCode: statusCode,
          );
          break;

        default:
          break;
        // throw Exception('채팅을 불러오는데 실패하였습니다.');
      }
    } catch (error) {
      print(error);
      state = state.copyWith(
        state: CursorPaginationError(
          message: '채팅을 불러오는데 실패하였습니다.',
        ),
      );
    }
  }

  @override
  dispose() {
    leaveRoom();
    repository.chatResponse.close();
    repository.socketOffAll();
    super.dispose();
  }

  void enterRoom() {
    repository.enterRoom();
    if (!initialized) {
      initialized = true;
      paginate(
        forceRefetch: true,
      );
    }
  }

  void leaveRoom() {
    repository.leaveRoom();
  }

  reJoinRoom() async {
    initialized = false;
    enterRoom();
  }

  // 백엔드에서 정상적인 200 데이터만 들어오도록 설계함
  _getMessageResProccess({
    required int statusCode,
    required dynamic resObj,
  }) {
    // 1. status code가 200 ~ 300이 아니면 에러를 발생시킨다.
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('채팅을 불러오는데 실패하였습니다.');
    }

    CursorPagination<ChatModel> pState;
    final state = this.state.currentState;
    // 2. 현재 state가 CursorpaginationError 이면 throw.
    if (state is CursorPaginationError) {
      throw Exception('채팅을 불러오는데 실패하였습니다.');
    }
    // 3. 만약 paginate를 1회라도 진행하지 않아서 meta가 없다면 meta를 임의생성함
    // 아래와 같이 로직을 짜는것이 비효율적이라고 생각할 수도 있지만
    // 실질적으로 state를 CusorPagination으로 고정해서 parsing을 해버리면
    // paginate가 갑자기 될수도 있음에 방지하기 위함임
    if (state is CursorPaginationLoading) {
      pState = CursorPagination<ChatModel>(
        meta: CursorPaginationMeta(
          // hasMore: false로 init 하는 이유
          // 어차피 이경우는 paginate가 getMessage보다 먼저 도착했을때를 대비하기위함임
          // 이경우는 hasMore가 false인 상태로 시작하고
          // 추후 paginate가 도착하면 hasMore를 res의 meta를 확인하고 변경해줌
          hasMore: false,
          count: 0,
        ),
        data: [],
      );
    } else if (state is CursorPagination) {
      pState = state as CursorPagination<ChatModel>;
    } else if (state is CursorPaginationFetchingMore) {
      pState = state as CursorPaginationFetchingMore<ChatModel>;
    } else {
      pState = state as CursorPaginationRefetching<ChatModel>;
    }

    // 3. chatMessage json으로부터 ChatModel을 생성한다.
    final chatMessage = ChatTempModel.fromJson(resObj['data']);

    // 4. 본인이 보낸 메시지인지 확인하기
    // 5. 본인이 보낸 메시지라면 tempMessageId를 찾아서 변경한다.
    if (chatMessage.userId == me.id) {
      final index = pState.data.indexWhere(
        (element) => element.id == chatMessage.tempMessageId,
      );
      if (index != -1) {
        pState.data[index] = chatMessage.parseToChatModel();
      }
    } else {
      // 3. 본인이 보낸 메시지가 아니라면 그냥 추가한다.
      // 4. 단 본인이 보낸 메시지 중 아직 도착하지 않은 ChatModelTemp가 있다면
      // 그것보다는 뒤에 배치한다

      final lastSuccessMessageIndex =
          pState.data.indexWhere((element) => element is! ChatTempModel);

      pState.data.insert(
        lastSuccessMessageIndex > 0 ? lastSuccessMessageIndex - 1 : 0,
        chatMessage.parseToChatModel(),
      );
    }

    // 3. 읽은 메시지를 확인하여 memberLastReadChatMap을 변경한다.
    Map<String, String?> memberLastReadChatMap =
        this.state.memberLastReadChatMap;
    for (var element in chatMessage.readUserIds) {
      memberLastReadChatMap[element] = chatMessage.id;
    }
    // 4. 추가된 데이터를 state에 추가한다.
    this.state = this.state.copyWith(
          state: pState.copyWith(
            data: pState.data,
          ),
          memberLastReadChatMap: memberLastReadChatMap,
        );

    print(this.state.memberLastReadChatMap);
  }

  _paginateMessageResProccess({
    required int statusCode,
    required dynamic resObj,
  }) async {
    // 1. status code가 200 ~ 300이 아니면 에러를 발생시킨다.
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('채팅을 불러오는데 실패하였습니다.');
    }
    final state = this.state.currentState;

    CursorPagination<ChatModel> pState;
    // 2. 현재 state가 CursorpaginationError 이면 throw.
    if (state is CursorPaginationError) {
      throw Exception('채팅을 불러오는데 실패하였습니다.');
    }

    final resp = CursorPagination<ChatModel>.fromJson(
      resObj['data'],
      (e) => ChatModel.fromJson(e as Map<String, dynamic>),
    );

    if (state is CursorPaginationLoading ||
        state is CursorPaginationRefetching) {
      this.state = this.state.copyWith(state: resp.copyWith());
      return;
    }
    pState = state as CursorPagination<ChatModel>;
    this.state = this.state.copyWith(
            state: resp.copyWith(data: [
          ...pState.data,
          ...resp.data,
        ]));
  }

  // 백엔드에서 비정상적인 데이터만 들어오도록 설계함
  _sendMessageResProccess({
    required int statusCode,
    required dynamic resObj,
  }) async {
    try {
      if (statusCode < 200 || statusCode >= 300) {
        final tempMessageId = resObj['tempMessageId'];

        CursorPagination<ChatModel> pState;
        final state = this.state.currentState;

        if (state is CursorPagination) {
          pState = state as CursorPagination<ChatModel>;
        } else if (state is CursorPaginationFetchingMore) {
          pState = state as CursorPaginationFetchingMore<ChatModel>;
        } else if (state is CursorPaginationRefetching) {
          pState = state as CursorPaginationRefetching<ChatModel>;
        } else {
          throw Exception('채팅을 불러오는데 실패하였습니다.');
        }

        final tempMessageIndex = pState.data.indexWhere((element) =>
            element is ChatTempModel && element.tempMessageId == tempMessageId);

        if (tempMessageIndex != -1) {
          pState.data[tempMessageIndex] =
              (pState.data[tempMessageIndex] as ChatTempModel)
                  .parseToChatFailedModel(resObj['message'] ?? '메시지 전송 실패');

          this.state = this.state.copyWith(
                  state: pState.copyWith(
                data: pState.data,
              ));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _enterRoomResProccess({
    required int statusCode,
    required dynamic resObj,
  }) async {
    // accessCode check를 진행하지 않아서 401 발생하지 않음
    try {
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception('채팅방에 입장하는데 실패하였습니다.');
      }

      final data = resObj['data'] as Map<String, dynamic>;
      final joinUserId = data['userId'] as String;
      final lastChatId = data['lastChatId'] as String;

      Map<String, String?> memberLastReadChatMap = state.memberLastReadChatMap;

      memberLastReadChatMap[joinUserId] = lastChatId;

      state = state.copyWith(
        memberLastReadChatMap: memberLastReadChatMap,
      );
    } catch (e) {
      print(e);
    }
  }
  /**
   * pagination_provider를 사용하지 않고 직접 throttle을 사용하여 구현
   * 이유 : pagination_provider와 겹치는 부분은 많기는 하지만
   * pagination_provider는 기본적으로 요청과 응답에 대한 처리가 일괄적인 반면에
   * 이 부분은 요청과 응답에 대한 처리가 다르기 때문에(stream을 통한 응답을 받아서 처리)
   * pagination_provider를 사용하기에는 어려움이 있음
   * 추후 pagination_provider를 사용할 수 있도록 수정 필요
   */ ///

  Future<void> paginate({
    int fetchCount = 30,
    bool fetchMore = false,
    bool forceRefetch = false,
    int bounceMilSec = 1000,
  }) async {
    EasyThrottle.throttle(
      randomKey,
      Duration(milliseconds: bounceMilSec),
      () => _throttlePagination(
        PaginationInfo(
          fetchCount: fetchCount,
          forceRefetch: forceRefetch,
          fetchMore: fetchMore,
        ),
      ),
    );
  }

  _throttlePagination(PaginationInfo info) async {
    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;

    try {
      // 5가지 상태
      // 1. CursorPagination - 정상적인 데이터 존재 상태
      // 2. CursorPaginationLoading - 로딩 중(현재 캐시 없음)
      // 3. CursorPaginationError - 에러 존재 상태
      // 4. CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때(맨 상단에서 재요청)
      // 5. CursorPaginationMoreLoading - 추가로 데이터를 가져올때 paginate상태임(맨 하단에서 재요청)

      // 바로 반환하는 상황
      // 1) hasMore이 false인 경우(기존 상태에서 이미 다음 데이터가 없다는 값을 가지고 있음)
      // 2) 로딩중 - fetchMore : true
      //    fetchMore이 false -> 새로고침의 의도를 가지고 있음
      // 2) 이외의 상황

      // 1번 반환 상황
      // 현재 값이 있는 상태이며(CusroPagination) 강제 refetch가 아닌 경우
      if (state.currentState is CursorPagination && !forceRefetch) {
        final pState = state.currentState as CursorPagination;

        // 데이터가 더이상 없는 경우
        if (!pState.meta.hasMore) {
          return;
        }
      }

      // 2번 반환 상황
      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;
      // 추가로 데이터를 가져오는 상황인데 이미 한번 요청해서 로딩중인 경우
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // 3번 반환 상황
      // count를 넣어줘야됨
      PaginationParams? paginationParams;

      // fetchMore 상황
      // 데이터를 추가로 더 가져오기
      if (fetchMore) {
        final pState = state.currentState as CursorPagination<ChatModel>;

        state = state.copyWith(
          state: CursorPaginationFetchingMore(
            meta: pState.meta,
            data: pState.data,
          ),
        );
        paginationParams =
            _generateParams(pState.data.lastOrNull, fetchCount, fetchMore);
      }
      // 처음부터 데이터를 가져오는 상황
      else {
        // 만약 데이터가 현재 있다면
        // 기존 데이터를 캐싱한 상태에서 Fetch(API 요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<ChatModel>;

          state = state.copyWith(
              state: CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          ));
        }
        // 현재 데이터가 없다면
        // 로딩 상태임을 반환함
        else {
          state = state.copyWith(state: CursorPaginationLoading());
        }
        paginationParams = _generateParams(null, fetchCount, fetchMore);
      }
      repository.paginate(
        paginationParams: paginationParams,
      );
      // 요청에 대한 응답은 StreamProvider를 통해 받음
    } catch (e) {
      print(e);
      state = state.copyWith(
        state: CursorPaginationError(message: '데이터 가져오기 실패'),
      );
    }
  }

  PaginationParams _generateParams(
    ChatModel? pState,
    int fetchCount,
    bool fetchMore,
  ) {
    if (pState == null) {
      return PaginationParams(
        count: fetchCount,
      );
    }
    final value = pState;
    return PaginationParams(
      after: fetchMore ? value.id : null,
      count: fetchCount,
    );
  }

  // state에 추가하여 관리해야됨
  // TODO : throttle 관리 진행 필요
  sendMessage({
    required String content,
  }) async {
    final state = this.state.currentState;
    // 1. state가 CursorPagination인지 확인 + user가 UserWithTokenModel인지 확인
    if (state is CursorPagination) {
      final accessToken =
          (await ref.read(secureStorageProvider).read(key: ACCESS_TOKEN_KEY))!;

      var pState = state as CursorPagination<ChatModel>;
      // 2. uuidv4를 이용하여 임시 아이디를 생성한다.
      final tempMessageId = const Uuid().v4();
      final now = DateTime.now();

      // 2. 서버에 요청을 보낸다.
      repository.sendMessage(
        roomId: roomId,
        content: content,
        tempMessageId: tempMessageId,
        accessToken: accessToken,
        createdAt: now.toString(),
      );
      // 3. 서버에 요청을 보낸 후, 서버에서 받은 데이터를 state에 추가한다.
      pState.data.insert(
        0,
        ChatTempModel(
          id: tempMessageId,
          content: content,
          createdAt: now,
          userId: me.id,
          readUserIds: [],
          tempMessageId: tempMessageId,
        ),
      );

      // 4. 변경된 데이터를 적용한다.
      this.state = this.state.copyWith(
            state: pState.copyWith(
              data: pState.data,
            ),
          );
    }
  }

  resendMessage({
    required String tempMessageId,
  }) async {
    final state = this.state.currentState;

    if (state is CursorPagination) {
      await ref.read(userProvider.notifier).getAccessTokenByRefreshToken();

      final accessToken =
          (await ref.read(secureStorageProvider).read(key: ACCESS_TOKEN_KEY))!;

      var pState = state as CursorPagination<ChatModel>;
      final tempMessageIndex = pState.data.indexWhere(
        (element) =>
            element is ChatFailedModel &&
            element.tempMessageId == tempMessageId,
      );
      if (tempMessageIndex != -1) {
        final tempMessage = pState.data[tempMessageIndex] as ChatFailedModel;

        final now = DateTime.now();

        repository.sendMessage(
          roomId: roomId,
          content: tempMessage.content,
          tempMessageId: tempMessage.tempMessageId,
          accessToken: accessToken,
          createdAt: now.toString(),
        );

        pState.data[tempMessageIndex] =
            tempMessage.parseToChatModelTemp(tempMessageId);

        this.state = this.state.copyWith(
              state: pState.copyWith(
                data: pState.data,
              ),
            );
      }
    }
  }

  deleteFailedMessage({
    required String tempMessageId,
  }) {
    if (state is CursorPagination) {
      var pState = state as CursorPagination<ChatModel>;
      final tempMessageIndex = pState.data.indexWhere(
        (element) =>
            element is ChatFailedModel &&
            element.tempMessageId == tempMessageId,
      );
      if (tempMessageIndex != -1) {
        pState.data.removeAt(tempMessageIndex);
        state = state.copyWith(
          state: pState.copyWith(
            data: pState.data,
          ),
        );
      }
    }
  }
}
