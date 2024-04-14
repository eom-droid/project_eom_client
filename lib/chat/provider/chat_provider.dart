import 'package:client/chat/model/chat_message_model.dart';
import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/repository/chat_repository.dart';

import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// final chatProvider =
//     StateNotifierProvider.family<ChatDetailModel?, String>((ref, roomId) {
//   final chatRepository = ref.watch(chatRepositoryProvider);
//   final me = ref.read(userProvider) as UserModel;

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

// final chatRoomStreamProvider = StreamProvider<ChatResponseModel>((ref) {
//   final chatRoomRepository = ref.read(chatRoomRepositoryProvider);
//   return chatRoomRepository.chatRoomResponse.stream;
// });

// 일단 임시로 Cursorpagination 을 사용하자
// 그리고 Cursorpagina

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

  init() async {
    // socketIO 연결
    await repository.init();
    // await Future.delayed(const Duration(milliseconds: 500), () {});
    // listner 등록
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
    print(state);

    repository.chatResponseStream.stream.listen(_listner);
  }

  _listner(ChatResponseModel resp) {
    try {
      final resObj = resp.data;
      final statusCode = resObj['status'];

      // switch (resp.state) {
      //   case ChatResponseState.getMessageRes:
      //     _getMessageResProccess(
      //       statusCode: statusCode,
      //       resObj: resObj,
      //     );
      //     break;
      //   case ChatResponseState.enterRoomRes:
      //     _enterRoomResProccess(
      //       resObj: resObj,
      //       statusCode: statusCode,
      //     );
      //     break;

      //   default:
      //     break;
      // }
    } catch (error) {
      state = CursorPaginationError(
        message: '채팅을 불러오는데 실패하였습니다.',
      );
    }
  }

  paginateMessage({
    required String roomId,
  }) async {
    EasyThrottle.throttle(
      randomKey,
      const Duration(milliseconds: 2000),
      () => _throttlePagination(
        roomId: roomId,
      ),
    );
  }

  _throttlePagination({
    required String roomId,
    bool forceRefetch = false,
  }) async {
    if (state is CursorPaginationError || state is CursorPaginationLoading) {
      return;
    }
    final pState = state as CursorPagination<ChatModel>;
    final selectedRoomIndex =
        pState.data.indexWhere((element) => element.id == roomId);

    if (selectedRoomIndex == -1) {
      return;
    }

    const paginationParams = PaginationParams();
    // 이미 한번 가져온 이력이 있는거임
    if (pState.data[selectedRoomIndex] is ChatDetailModel || forceRefetch) {
      final messages =
          (pState.data[selectedRoomIndex] as ChatDetailModel).messages;

      if (messages.isNotEmpty ||
          messages.last is! ChatMessageTempModel ||
          messages.last is! ChatMessageFailedModel) {
        paginationParams.copyWith(
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
  }

  // // message를 send한 이후 오는 sendMessageRes는 에러에 대한 처리만 진행하면됨
  // // - 유저가 보낸 메시지가 모종의 이유로 실패했을 때
  // // - 성공하면 getMessageRes로 오게됨

  // _getChatRoomRes({
  //   required int statusCode,
  //   required dynamic resObj,
  // }) async {
  //   if (statusCode >= 200 && statusCode < 300) {
  //     final chatRooms = resObj['data'] as List<dynamic>;

  //     final chatRoomModels =
  //         chatRooms.map((e) => ChatModel.fromJson(e)).toList();
  //     state = CursorPagination<ChatModel>(
  //       meta: CursorPaginationMeta(
  //         hasMore: false,
  //         count: chatRoomModels.length,
  //       ),
  //       data: chatRoomModels,
  //     );
  //   }
  // }

  // // 백엔드에서 정상적인 200 데이터만 들어오도록 설계함
  // _getMessageResProccess({
  //   required int statusCode,
  //   required dynamic resObj,
  // }) {
  //   // 1. status code가 200 ~ 300이 아니면 에러를 발생시킨다.
  //   if (statusCode < 200 || statusCode >= 300) {
  //     throw Exception('채팅을 불러오는데 실패하였습니다.');
  //   }

  //   // 2. 현재 state가 CursorpaginationError 이면 throw.
  //   // state가 CursorPagination || CursorPaginationRefetching || CursorPaginationFetchingMore이 아닐 수 없음
  //   // setLastChat으로 초기화를 진행하였기 때문
  //   if (state is CursorPaginationError || state is CursorPaginationLoading) {
  //     throw Exception('채팅을 불러오는데 실패하였습니다.');
  //   }

  //   CursorPagination<ChatModel> pState = state as CursorPagination<ChatModel>;

  //   // 3. chatMessage json으로부터 ChatModel을 생성한다.
  //   final chatMessage = ChatMessageTempModel.fromJson(resObj['data']);

  //   // 3-1. chatMessage의 roomId를 찾는다.
  //   final roomId = resObj['roomId'] as String;
  //   // 3-2. pState에서 roomIndex를 찾는다.
  //   final roomIndex = pState.data.indexWhere((element) => element.id == roomId);
  //   if (roomIndex == -1) {
  //     return;
  //   }

  //   // 4. 본인이 보낸 메시지인지 확인하기
  //   // 5. 본인이 보낸 메시지라면 tempMessageId를 찾아서 변경한다.
  //   if (chatMessage.userId == me.id) {
  //     final messageIndex = pState.data[roomIndex].messages.indexWhere(
  //       (element) => element.id == chatMessage.tempMessageId,
  //     );
  //     if (messageIndex != -1) {
  //       pState.data[roomIndex].messages[messageIndex] =
  //           chatMessage.parseToChatModel();
  //     }
  //   } else {
  //     // 본인이 보낸 메시지가 아니라면 그냥 추가한다.
  //     // 단 본인이 보낸 메시지 중 아직 도착하지 않은 ChatModelTemp가 있다면
  //     // 그것보다는 뒤에 배치한다

  //     final lastSuccessMessageIndex =
  //         pState.data.indexWhere((element) => element is! ChatMessageTempModel);

  //     pState.data[roomIndex].messages.insert(
  //       lastSuccessMessageIndex > 0 ? lastSuccessMessageIndex - 1 : 0,
  //       chatMessage.parseToChatModel(),
  //     );
  //   }

  //   // 6. 읽은 메시지를 확인하여 member를 변경한다.
  //   pState.data[roomIndex] = pState.data[roomIndex].copyWith(
  //     members: pState.data[roomIndex].members.map(
  //       (user) {
  //         if (chatMessage.readUserIds.contains(user.id)) {
  //           return user.copyWith(
  //             lastReadChatId: chatMessage.id,
  //           );
  //         }
  //         return user;
  //       },
  //     ).toList(),
  //   );

  //   // 5. 추가된 데이터를 state에 추가한다.
  //   state = pState.copyWith(
  //     data: pState.data,
  //   );
  // }

  // // 메시지 페이지네이팅임
  // _paginateMessageResProccess({
  //   required int statusCode,
  //   required dynamic resObj,
  // }) async {
  //   // 1. status code가 200 ~ 300이 아니면 에러를 발생시킨다.
  //   if (statusCode < 200 || statusCode >= 300) {
  //     throw Exception('채팅을 불러오는데 실패하였습니다.');
  //   }

  //   // 2. 현재 state가 CursorpaginationError 이면 throw.
  //   // state가 CursorPaginationLoading일수가 없음 paginateMessageRes는 무조건 CursorPagination이어야 함
  //   if (state is CursorPaginationError || state is CursorPaginationLoading) {
  //     throw Exception('채팅을 불러오는데 실패하였습니다.');
  //   }

  //   // 3. 필요한 변수들 선언해주고
  //   final resp = CursorPagination<ChatMessageModel>.fromJson(
  //     resObj['data'],
  //     (e) => ChatMessageModel.fromJson(e as Map<String, dynamic>),
  //   );
  //   final roomId = resObj['roomId'] as String;
  //   final pState = state as CursorPagination<ChatModel>;
  //   final currentRoomIndex =
  //       pState.data.indexWhere((element) => element.id == roomId);

  //   // 4. 만약 roomId가 없다면 그냥 리턴
  //   if (currentRoomIndex == -1) {
  //     return;
  //   }
  //   // 5. hasMoreMessage를 변경해준다.
  //   // 6. 메시지를 추가해준다
  //   pState.data[currentRoomIndex] = pState.data[currentRoomIndex].copyWith(
  //     hasMoreMessage: resp.meta.hasMore,
  //     messages: [
  //       ...pState.data[currentRoomIndex].messages,
  //       ...resp.data,
  //     ],
  //   );

  //   // 7. state 변경
  //   state = pState.copyWith(
  //     data: pState.data,
  //   );
  // }

  // void enterRoom(String roomId) {
  //   if (state is CursorPaginationError || state is CursorPaginationLoading) {
  //     return;
  //   }

  //   final pState = state as CursorPagination<ChatModel>;
  //   repository.enterRoom(roomId);
  //   final currentRoomIndex =
  //       pState.data.indexWhere((element) => element.id == roomId);
  //   if (currentRoomIndex != -1 && !pState.data[currentRoomIndex].entered) {
  //     state = pState.copyWith(
  //       data: pState.data
  //           .map(
  //             (e) => e.id == roomId
  //                 ? e.copyWith(
  //                     entered: true,
  //                   )
  //                 : e,
  //           )
  //           .toList(),
  //     );

  //     // paginateMessage(
  //     //   roomId: roomId,
  //     // );
  //   }
  // }

  // // 기본이 fetchMore임
  // paginateMessage({
  //   required String roomId,
  //   bool forceRefetch = false,
  // }) {
  //   if (state is CursorPaginationError || state is CursorPaginationLoading) {
  //     return;
  //   }

  //   final pState = state as CursorPagination<ChatModel>;
  //   final currentRoomIndex =
  //       pState.data.indexWhere((element) => element.id == roomId);

  //   if (currentRoomIndex == -1) {
  //     return;
  //   }

  //   final afterMessageId =
  //       pState.data[currentRoomIndex].messages.isEmpty || forceRefetch
  //           ? null
  //           : pState.data[currentRoomIndex].messages.last.id;
  //   if (forceRefetch) {
  //     // forceRefetch 시 메시지를 초기화한다.
  //     state = pState.copyWith(
  //       data: pState.data
  //           .map(
  //             (e) => e.id == roomId
  //                 ? e.copyWith(
  //                     messages: [],
  //                   )
  //                 : e,
  //           )
  //           .toList(),
  //     );
  //   }

  //   repository.paginateMessage(
  //     roomId: roomId,
  //     paginationParams: PaginationParams(after: afterMessageId),
  //   );
  // }

  // _sendMessageResProccess({
  //   required int statusCode,
  //   required dynamic resObj,
  // }) {
  //   try {
  //     // 정상적인 범주로 들어오지 않음
  //     if (statusCode < 200 || statusCode >= 300) {
  //       if (state is CursorPaginationError ||
  //           state is CursorPaginationLoading) {
  //         return;
  //       }
  //       final pState = state as CursorPagination<ChatModel>;
  //       final tempMessageId = resObj['tempMessageId'];
  //       final roomId = resObj['roomId'];
  //       final currentRoomIndex =
  //           pState.data.indexWhere((element) => element.id == roomId);

  //       if (currentRoomIndex == -1) {
  //         return;
  //       }

  //       final tempMessageIndex = pState.data[currentRoomIndex].messages
  //           .indexWhere((element) =>
  //               element is ChatMessageTempModel &&
  //               element.tempMessageId == tempMessageId);

  //       if (tempMessageIndex == -1) {
  //         return;
  //       }

  //       pState.data[currentRoomIndex].messages[tempMessageIndex] = (pState
  //               .data[currentRoomIndex]
  //               .messages[tempMessageIndex] as ChatMessageTempModel)
  //           .parseToChatFailedModel(
  //         resObj['message'] ?? '메시지 전송 실패',
  //       );

  //       state = pState.copyWith(
  //         data: pState.data,
  //       );
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // // 개별적인 getMessageResProcess에서 읽은 유저에 대한 관리를 진행하지만
  // // 만약 메시지를 서로 보내지 않는 상태에서 1 유저가 들어오고 2유저가 들어오게 되면 1유저에게 2유저가 읽었다는 정보를 전달해주어야함
  // _enterRoomResProccess({
  //   required int statusCode,
  //   required dynamic resObj,
  // }) {
  //   // accessCode check를 진행하지 않아서 401 발생하지 않음
  //   try {
  //     if (statusCode < 200 || statusCode >= 300) {
  //       throw Exception('채팅방에 입장하는데 실패하였습니다.');
  //     }

  //     final roomId = resObj['roomId'] as String;
  //     final data = resObj['data'] as Map<String, dynamic>;
  //     if (state is CursorPaginationError || state is CursorPaginationLoading) {
  //       return;
  //     }

  //     if (data['lastChatId'] != null) {
  //       final joinUserId = data['userId'] as String;
  //       final lastChatId = data['lastChatId'] as String;
  //       final pState = state as CursorPagination<ChatModel>;
  //       final currentRoomIndex =
  //           pState.data.indexWhere((element) => element.id == roomId);
  //       if (currentRoomIndex == -1) {
  //         return;
  //       }

  //       pState.data[currentRoomIndex] = pState.data[currentRoomIndex].copyWith(
  //         members: pState.data[currentRoomIndex].members.map(
  //           (user) {
  //             if (user.id == joinUserId) {
  //               return user.copyWith(
  //                 lastReadChatId: lastChatId,
  //               );
  //             }
  //             return user;
  //           },
  //         ).toList(),
  //       );

  //       state = pState.copyWith(
  //         data: pState.data,
  //       );
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<void> reconnect({
  //   dynamic Function(dynamic)? onConnectCallback,
  // }) async {
  //   final accessToken =
  //       await ref.read(userProvider.notifier).getAccessTokenByRefreshToken();
  //   repository.reconnect(
  //     accessToken: accessToken,
  //     onConnectCallback: onConnectCallback,
  //   );
  // }

  // void test() {
  //   repository.test();
  // }

  // sendMessage({
  //   required String content,
  //   required String roomId,
  // }) async {
  //   test();
  //   // 1. state가 CursorPagination인지 확인 + user가 UserWithTokenModel인지 확인
  //   // if (state is CursorPagination) {
  //   //   final accessToken =
  //   //       (await ref.read(secureStorageProvider).read(key: ACCESS_TOKEN_KEY))!;

  //   //   var pState = state as CursorPagination<ChatModel>;
  //   //   // 2. uuidv4를 이용하여 임시 아이디를 생성한다.
  //   //   final tempMessageId = const Uuid().v4();
  //   //   final now = DateTime.now();

  //   //   // 2. 서버에 요청을 보낸다.
  //   //   repository.sendMessage(
  //   //     roomId: roomId,
  //   //     content: content,
  //   //     tempMessageId: tempMessageId,
  //   //     accessToken: accessToken,
  //   //     createdAt: now.toString(),
  //   //   );
  //   //   // 3. 서버에 요청을 보낸 후, 서버에서 받은 데이터를 state에 추가한다.
  //   //   pState.data[pState.data.indexWhere((element) => element.id == roomId)]
  //   //       .messages
  //   //       .insert(
  //   //     0,
  //   //     ChatMessageTempModel(
  //   //       id: tempMessageId,
  //   //       content: content,
  //   //       createdAt: now,
  //   //       userId: me.id,
  //   //       readUserIds: [],
  //   //       tempMessageId: tempMessageId,
  //   //     ),
  //   //   );

  //   //   // 4. 변경된 데이터를 적용한다.
  //   //   state = pState.copyWith(
  //   //     data: pState.data,
  //   //   );
  //   // }
  // }

  // void reJoinRoom(String roomId) async {
  //   // 1. socket의 연결이 해제되어 있을때
  //   // 전체적인 방을 다시 불러온다.
  //   // if (repository.socket.socket.connected) {
  //   state = CursorPaginationLoading();
  //   await reconnect(
  //       // onConnectCallback: (_) async {
  //       //   await Future.delayed(const Duration(milliseconds: 500), () {});

  //       //   enterRoom(roomId);

  //       // },
  //       );
  //   enterRoom(roomId);
  //   // } else {
  //   //   enterRoom(roomId);
  //   // }
  // }

  // // void paginateMessage(String roomId) async{
  // //   if (state is CursorPagination) {
  // //     final pState = state as CursorPagination<ChatModel>;
  // //     final currentRoom = pState.data.firstWhereOrNull((element) => element.isCurrentRoom);
  // //     if(currentRoom == null){
  // //       return;
  // //     }
  // //     final lastMessageId = currentRoom.messages.last.id;
  // //     repository.paginateMessage(roomId: currentRoom.id, lastMessageId: lastMessageId);
  // //   }
  // // }
  // void leaveRoom(String roomId) {
  //   repository.leaveRoom(roomId);
  // }
}
