import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/repository/chat_repository.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/user/model/user_with_token_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:uuid/uuid.dart';

final chatProvider = StateNotifierProvider.family<ChatStateNotifier,
    CursorPaginationBase, String>((ref, roomId) {
  final chatRepository = ref.watch(chatRepositoryProvider(roomId));
  final user = ref.watch(userProvider);

  return ChatManageStateNotifier(
    repository: chatRepository,
    user: user!,
    ref: ref,
  ).getChatNotifier(
    roomId: roomId,
  );
});

class ChatManageStateNotifier
    extends StateNotifier<Map<String, ChatStateNotifier>> {
  final ChatRepository repository;
  final StateNotifierProviderRef ref;
  final UserWithTokenModelBase? user;
  ChatManageStateNotifier({
    required this.repository,
    required this.user,
    required this.ref,
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

    state[roomId] = ChatStateNotifier(
      repository: repository,
      user: user,
      roomId: roomId,
      ref: ref,
    );

    return state[roomId]!;
  }
}

final chatStreamProvider =
    StreamProvider.family<ChatResponseModel, String>((ref, roomId) {
  final chatRepository = ref.read(chatRepositoryProvider(roomId));
  return chatRepository.chatResponse.stream;
});

class ChatStateNotifier extends StateNotifier<CursorPaginationBase> {
  final ChatRepository repository;
  final UserWithTokenModelBase? user;
  final StateNotifierProviderRef ref;
  final String roomId;
  late final String randomKey;

  ChatStateNotifier({
    required this.repository,
    required this.user,
    required this.roomId,
    required this.ref,
  }) : super(CursorPaginationLoading()) {
    Uuid uuid = const Uuid();
    randomKey = uuid.v4();
    repository.joinRoom(
      accessToken: (user as UserWithTokenModel).token.accessToken,
    );
    repository.onGetMessageRes();
    repository.onPaginateMessageRes();
    repository.onJoinRoomRes();
    ref.listen(
      chatStreamProvider(roomId),
      (previous, AsyncValue<ChatResponseModel> next) {
        try {
          // 1. next.value가 null이면 에러를 발생시킨다.
          if (next.value == null) {
            throw Exception('채팅을 불러오는데 실패하였습니다.');
          }
          final resObj = next.value!.data;
          final statusCode = resObj['status'];
          // 2. status code가 200 ~ 300이 아니면 에러를 발생시킨다.
          if (statusCode < 200 || statusCode >= 300) {
            throw Exception('채팅을 불러오는데 실패하였습니다.');
          }

          CursorPagination<ChatModel> pState;
          // 3. 현재 state가 CursorPagination 이거나 CursorPaginationLoading이 아니라면 에러.
          if (state is CursorPagination) {
            pState = state as CursorPagination<ChatModel>;
          } else if (state is CursorPaginationLoading) {
            pState = CursorPagination<ChatModel>(
              meta: CursorPaginationMeta(
                hasMore: false,
                count: 0,
              ),
              data: [],
            );
          } else {
            throw Exception('채팅을 불러오는데 실패하였습니다.');
          }

          switch (next.value!.state) {
            case ChatResponseState.getMessageRes:
              final chatMessage = ChatModel.fromJson(resObj['data']);
              state = pState.copyWith(
                data: [
                  chatMessage,
                  ...pState.data,
                ],
              );
              break;
            case ChatResponseState.paginateMessageRes:
              final resp = CursorPagination<ChatModel>.fromJson(
                resObj['data'],
                (e) => ChatModel.fromJson(e as Map<String, dynamic>),
              );

              state = resp.copyWith(meta: resp.meta, data: [
                ...pState.data,
                ...resp.data,
              ]);
              break;
            default:
              break;
            // throw Exception('채팅을 불러오는데 실패하였습니다.');
          }
        } catch (error) {
          state = CursorPaginationError(message: '채팅을 불러오는데 실패하였습니다.');
        }
      },
    );
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
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;
        print(pState.meta.hasMore);

        // 데이터가 더이상 없는 경우
        if (!pState.meta.hasMore) {
          return;
        }
      }

      // 2번 반환 상황
      final isLoading = state is CursorPaginationLoading;
      final isFetchingMore = state is CursorPaginationFetchingMore;
      // 추가로 데이터를 가져오는 상황인데 이미 한번 요청해서 로딩중인 경우
      if (fetchMore && (isLoading || isFetchingMore)) {
        return;
      }

      // 3번 반환 상황
      // count를 넣어줘야됨
      PaginationParams? paginationParams;

      // fetchMore 상황
      // 데이터를 추가로 더 가져오기
      if (fetchMore) {
        final pState = state as CursorPagination<ChatModel>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
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

          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 현재 데이터가 없다면
        // 로딩 상태임을 반환함
        else {
          state = CursorPaginationLoading();
        }
        paginationParams = _generateParams(null, fetchCount, fetchMore);
      }

      repository.paginate(
        paginationParams: paginationParams,
        accessToken: (user as UserWithTokenModel).token.accessToken,
      );
      // 요청에 대한 응답은 StreamProvider를 통해 받음
    } catch (e) {
      print(e);
      state = CursorPaginationError(message: '데이터 가져오기 실패');
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
  postMessage({
    required String content,
  }) async {
    // 1. state가 CursorPagination인지 확인 + user가 UserWithTokenModel인지 확인
    if (state is CursorPagination && user is UserWithTokenModel) {
      final user = this.user as UserWithTokenModel;

      var pState = state as CursorPagination<ChatModel>;
      // 2. uuidv4를 이용하여 임시 아이디를 생성한다.
      final tempMessageId = const Uuid().v4();

      // 2. 서버에 요청을 보낸다.
      repository.postMessage(
        roomId: roomId,
        content: content,
        tempMessageId: tempMessageId,
        accessToken: user.token.accessToken,
      );
      // 3. 서버에 요청을 보낸 후, 서버에서 받은 데이터를 state에 추가한다.
      pState.data.insert(
        0,
        ChatModelTemp(
          id: tempMessageId,
          content: content,
          createdAt: DateTime.now(),
          userId: user.user.id,
        ),
      );

      // 4. 변경된 데이터를 적용한다.
      state = pState.copyWith(
        data: pState.data,
      );
    }
  }
}
