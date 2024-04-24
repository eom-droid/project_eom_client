import 'package:client/chat/const/chat_default.dart';
import 'package:client/chat/model/chat_message_model.dart';
import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/repository/chat_repository.dart';
import 'package:client/chat/view/chat_detail_screen.dart';
import 'package:client/common/const/data.dart';

import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatDetailProvider =
    Provider.family<ChatDetailModel?, String>((ref, roomId) {
  final chatState = ref.watch(chatProvider);
  if (chatState is CursorPagination) {
    final result =
        chatState.data.firstWhereOrNull((element) => element.id == roomId);
    if (result is ChatDetailModel) {
      return result;
    }
  }
  return null;
});

final chatProvider =
    StateNotifierProvider<ChatStateNotifier, CursorPaginationBase>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final me = ref.read(userProvider) as UserModel;

  return ChatStateNotifier(
    repository: chatRepository,
    me: me,
    ref: ref,
  );
});

class ChatStateNotifier extends StateNotifier<CursorPaginationBase> {
  final ChatRepository repository;
  final UserModel me;
  final Ref ref;
  final String randomKey = const Uuid().v4();

  ChatStateNotifier({
    required this.repository,
    required this.me,
    required this.ref,
  }) : super(CursorPaginationLoading()) {
    init();
  }

  onSocketError(dynamic message) {
    state = CursorPaginationError(message: '채팅을 불러오는데 실패하였습니다.');
  }

  // 에러 발생에 따른 재시도
  reconnect() {
    state = CursorPaginationLoading();
    init(reInit: true);
  }

  leaveRoom(String roomId) {
    repository.leaveRoom(roomId);
  }

  // 백그라운드에서 포그라운드로 돌아올때
  reJoinRoom({
    required String roomId,
    required String route,
  }) {
    if (repository.socket.socket.connected) {
      // 1-2. socket의 연결이 되어있을때는 enterRoom만 진행한다. && route가 ChatDetailScreen일때만 진행
      if (route == ChatDetailScreen.routeName) {
        enterRoom(roomId);
      }
    } else {
      state = CursorPaginationLoading();
      // 1-1. socket의 연결이 해제 되어있을때는 전체적인 방을 다시 불러온다.
      init(reInit: true);
    }
  }

  Future<void> init({
    bool reInit = false,
  }) async {
    if (!reInit) {
      repository.chatResponseStream.stream.listen(_listner);
    }
    await connectSocket(reInit: reInit);
    await getChatRoom();
  }

  Future<void> connectSocket({
    bool reInit = false,
  }) async {
    // socketIO 연결
    final result = await repository.init(reInit: reInit);
    if (!result) {
      state = CursorPaginationError(message: '채팅을 불러오는데 앱을 재시작해주세요.');
    }
  }

  Future<void> getChatRoom() async {
    final chatRoom = await repository.getChatRoom();
    if (chatRoom == null) {
      state = CursorPaginationError(message: '채팅을 불러오는데 실패하였습니다.');
      return;
    }

    state = CursorPagination<ChatModel>(
      meta: CursorPaginationMeta(
        hasMore: false,
        count: chatRoom.length,
      ),
      data: chatRoom,
    );
  }

  _listner(ChatResponseModel resp) {
    try {
      final resObj = resp.data;
      final statusCode = resObj['status'];

      switch (resp.event) {
        case SocketEvent.newMessage:
          _newMessageCallback(
            statusCode: statusCode,
            resObj: resObj,
          );
          break;
        case SocketEvent.enterRoomOtherUser:
          _enterRoomOtherUserCallback(
            statusCode: statusCode,
            resObj: resObj,
          );
          break;
        default:
          break;
      }
    } catch (error) {
      state = CursorPaginationError(
        message: '채팅을 불러오는데 실패하였습니다.',
      );
    }
  }

  // 본인 메시지도 여기에 포함되어있음
  // 왜냐면 본인이 보낸 메시지가 서버에서 다시 내려오기 때문 -> 자체 동기화해주기위해서?
  _newMessageCallback({
    required int statusCode,
    required dynamic resObj,
  }) {
    // 1. status code가 200 ~ 300이 아니면 에러를 발생시킨다.
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('채팅을 불러오는데 실패하였습니다.');
    }

    // 2. 현재 state가 CursorpaginationError 이면 throw.
    // state가 CursorPagination || CursorPaginationRefetching || CursorPaginationFetchingMore이 아닐 수 없음
    // setLastChat으로 초기화를 진행하였기 때문
    if (state is CursorPaginationError || state is CursorPaginationLoading) {
      return;
    }

    CursorPagination<ChatModel> pState = state as CursorPagination<ChatModel>;

    // 3. chatMessage json으로부터 ChatModel을 생성한다.
    final chatMessage = ChatMessageTempModel.fromJson(resObj['data']);

    // 3-1. chatMessage의 roomId를 찾는다.
    final roomId = resObj['roomId'] as String;
    // 3-2. pState에서 roomIndex를 찾는다.
    final roomIndex = pState.data.indexWhere((element) => element.id == roomId);
    if (roomIndex == -1) {
      return;
    }

    if (pState.data[roomIndex] is ChatDetailModel) {
      // 4. 본인이 보낸 메시지인지 확인하기
      // 5. 본인이 보낸 메시지라면 tempMessageId를 찾아서 변경한다.
      if (chatMessage.userId == me.id) {
        final messageIndex =
            (pState.data[roomIndex] as ChatDetailModel).messages.indexWhere(
                  // sendMessage 시 id에 tempMessageId를 넣어주었음
                  (element) => element.id == chatMessage.tempMessageId,
                );
        if (messageIndex != -1) {
          (pState.data[roomIndex] as ChatDetailModel).messages[messageIndex] =
              chatMessage.parseToChatModel();
        }
      } else {
        // 본인이 보낸 메시지가 아니라면 그냥 추가한다.
        // 단 본인이 보낸 메시지 중 아직 도착하지 않은 ChatModelTemp가 있다면
        // 그것보다는 뒤에 배치한다

        final lastSuccessMessageIndex = pState.data
            .indexWhere((element) => element is! ChatMessageTempModel);

        (pState.data[roomIndex] as ChatDetailModel).messages.insert(
              lastSuccessMessageIndex > 0 ? lastSuccessMessageIndex - 1 : 0,
              chatMessage.parseToChatModel(),
            );
      }
    } else {
      pState.data[roomIndex] = pState.data[roomIndex].copyWith(
        lastMessage: chatMessage.parseToChatModel(),
      );
    }

    // 6. 읽은 메시지를 확인하여 member를 변경한다.
    pState.data[roomIndex] = pState.data[roomIndex].copyWith(
      members: pState.data[roomIndex].members.map(
        (user) {
          if (chatMessage.readUserIds.contains(user.id)) {
            return user.copyWith(
              lastReadChatId: chatMessage.id,
            );
          }
          return user;
        },
      ).toList(),
    );

    // 5. 추가된 데이터를 state에 추가한다.
    state = pState.copyWith(
      data: pState.data,
    );
  }

  _enterRoomOtherUserCallback({
    required int statusCode,
    required dynamic resObj,
  }) {
    // accessCode check를 진행하지 않아서 401 발생하지 않음
    // 발생할 일이 없음
    if (statusCode < 200 || statusCode >= 300) {
      return;
    }

    final roomId = resObj['roomId'] as String;
    final data = resObj['data'] as Map<String, dynamic>;
    if (state is CursorPaginationError || state is CursorPaginationLoading) {
      return;
    }

    if (data['lastChatId'] != null) {
      final joinUserId = data['userId'] as String;
      final lastChatId = data['lastChatId'] as String;
      final pState = state as CursorPagination<ChatModel>;
      final currentRoomIndex =
          pState.data.indexWhere((element) => element.id == roomId);
      if (currentRoomIndex == -1) {
        return;
      }

      pState.data[currentRoomIndex] = pState.data[currentRoomIndex].copyWith(
        members: pState.data[currentRoomIndex].members.map(
          (user) {
            if (user.id == joinUserId) {
              return user.copyWith(
                lastReadChatId: lastChatId,
              );
            }
            return user;
          },
        ).toList(),
      );

      state = pState.copyWith(
        data: pState.data,
      );
    }
  }

  paginateMessage({
    required String roomId,
    bool forceRefetch = false,
  }) async {
    EasyThrottle.throttle(
      randomKey,
      const Duration(milliseconds: 2000),
      () => _throttlePagination(
        roomId: roomId,
        forceRefetch: forceRefetch,
      ),
    );
  }

  _throttlePagination({
    required String roomId,
    required bool forceRefetch,
  }) async {
    if (state is CursorPaginationError || state is CursorPaginationLoading) {
      return;
    }
    final pState = state as CursorPagination<ChatModel>;
    final selectedRoomIndex =
        pState.data.indexWhere((element) => element.id == roomId);

    // 파라미터로 준 roomID에 해당되는 방이 없는 경우
    if (selectedRoomIndex == -1) {
      return;
    }
    // 추가적으로 더 있는 경우
    if (pState.data[selectedRoomIndex] is ChatDetailModel &&
        (pState.data[selectedRoomIndex] as ChatDetailModel).hasMoreMessage ==
            false) {
      return;
    }

    PaginationParams paginationParams = const PaginationParams();
    // 이미 한번 가져온 이력이 있는거임
    if (pState.data[selectedRoomIndex] is ChatDetailModel && !forceRefetch) {
      final messages =
          (pState.data[selectedRoomIndex] as ChatDetailModel).messages;

      if (messages.isNotEmpty ||
          messages.last is! ChatMessageTempModel ||
          messages.last is! ChatMessageFailedModel) {
        paginationParams = paginationParams.copyWith(
          after: messages.last.id,
        );
      }
    }

    final resp = await repository.paginateMessage(
      roomId: roomId,
      paginationParams: paginationParams,
    );

    if (resp == null) {
      state = CursorPaginationError(
        message: '채팅을 불러오는데 실패하였습니다.',
      );
      return;
    }

    if (pState.data[selectedRoomIndex] is! ChatDetailModel || forceRefetch) {
      state = pState.copyWith(
        data: pState.data.map(
          (e) {
            if (e.id == roomId) {
              return e.toDetailModel(
                hasMoreMessage: resp.meta.hasMore,
                messages: resp.data,
              );
            }
            return e;
          },
        ).toList(),
      );
    } else {
      state = pState.copyWith(
        data: pState.data.map(
          (e) {
            if (e.id == roomId) {
              return (e as ChatDetailModel).copyWith(
                hasMoreMessage: resp.meta.hasMore,
                messages: [
                  ...e.messages,
                  ...resp.data,
                ],
              );
            }
            return e;
          },
        ).toList(),
      );
    }
  }

  Future<void> enterRoom(String roomId) async {
    if (state is CursorPaginationError || state is CursorPaginationLoading) {
      return;
    }

    final pState = state as CursorPagination<ChatModel>;
    final lastChatId = await repository.enterRoom(roomId);
    final currentRoomIndex =
        pState.data.indexWhere((element) => element.id == roomId);
    if (currentRoomIndex == -1) {
      return;
    }
    if (pState.data[currentRoomIndex] is! ChatDetailModel) {
      await paginateMessage(roomId: roomId);
    }

    pState.data[currentRoomIndex] = pState.data[currentRoomIndex].copyWith(
      members: pState.data[currentRoomIndex].members.map(
        (user) {
          if (user.id == me.id) {
            return user.copyWith(
              lastReadChatId: lastChatId,
            );
          }
          return user;
        },
      ).toList(),
    );

    state = pState.copyWith(
      data: pState.data,
    );
  }

  postMessage({
    required String content,
    required String roomId,
  }) async {
    // 1. state가 CursorPagination인지 확인 + user가 UserWithTokenModel인지 확인
    if (state is CursorPagination) {
      final accessToken =
          (await ref.read(secureStorageProvider).read(key: ACCESS_TOKEN_KEY))!;

      var pState = state as CursorPagination<ChatModel>;
      // 2. uuidv4를 이용하여 임시 아이디를 생성한다.
      final tempMessageId = const Uuid().v4();
      final now = DateTime.now();

      // 2. 서버에 요청을 보낸다.
      repository
          .postMessage(
        roomId: roomId,
        content: content,
        tempMessageId: tempMessageId,
        accessToken: accessToken,
      )
          .then((error) {
        if (error != null) {
          // 현재 상태에서 메시지를 chatMessageFailedModel로 변경한다
          if (state is CursorPaginationError ||
              state is CursorPaginationLoading) {
            return;
          }
          var pState = state as CursorPagination<ChatModel>;
          var currentRoomIndex =
              pState.data.indexWhere((element) => element.id == roomId);
          if (currentRoomIndex == -1 ||
              pState.data[currentRoomIndex] is! ChatDetailModel) {
            return;
          }
          var selectedChatMessageIndex =
              (pState.data[currentRoomIndex] as ChatDetailModel)
                  .messages
                  .indexWhere((element) => element.id == tempMessageId);

          if (selectedChatMessageIndex == -1) {
            return;
          }

          (pState.data[currentRoomIndex] as ChatDetailModel)
              .messages[selectedChatMessageIndex] = ChatMessageFailedModel(
            id: tempMessageId,
            content: content,
            createdAt: now,
            userId: me.id,
            error: "",
            tempMessageId: tempMessageId,
          );
        }
      });

      // 3. 서버에 요청을 보낸 후, 서버에서 받은 데이터를 state에 추가한다.
      (pState.data[pState.data.indexWhere((element) => element.id == roomId)]
              as ChatDetailModel)
          .messages
          .insert(
            0,
            ChatMessageTempModel(
              id: tempMessageId,
              content: content,
              createdAt: now,
              userId: me.id,
              readUserIds: [],
              tempMessageId: tempMessageId,
            ),
          );

      // 4. 변경된 데이터를 적용한다.
      state = pState.copyWith(
        data: pState.data,
      );
    }
  }
}
