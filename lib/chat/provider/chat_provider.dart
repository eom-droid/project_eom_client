import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/repository/chat_repository.dart';
import 'package:client/user/model/user_with_token_model.dart';
import 'package:client/user/provider/user_provider.dart';
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
  ChatStateNotifier({
    required this.repository,
    required this.user,
    required this.roomId,
    required this.ref,
  }) : super(CursorPaginationLoading()) {
    repository.joinRoom(
      accessToken: (user as UserWithTokenModel).token.accessToken,
    );
    repository.onGetMessageRes();
    repository.onPaginateMessageRes();
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
              throw Exception('채팅을 불러오는데 실패하였습니다.');
          }
        } catch (error) {
          state = CursorPaginationError(message: '채팅을 불러오는데 실패하였습니다.');
        }
      },
    );
  }

  // state에 추가하여 관리해야됨
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

  // void toggleLike({
  //   required String commentId,
  // }) {
  //   if (state is CursorPagination) {
  //     var pState = state as CursorPagination<chatModel>;

  //     // 1. 선택된 chatId를 찾는다.
  //     final selecteComment = pState.data.indexWhere(
  //       (element) => element.id == commentId,
  //     );

  //     // 2. 만약 선택된 chatId가 없다면 그냥 리턴
  //     if (selecteComment == -1) {
  //       return;
  //     }

  //     // 3. 선택된 chatId가 있다면 해당 데이터를 변경한다.
  //     pState.data[selecteComment] = pState.data[selecteComment].copyWith(
  //       isLike: !pState.data[selecteComment].isLike,
  //       likeCount: pState.data[selecteComment].likeCount +
  //           (pState.data[selecteComment].isLike ? -1 : 1),
  //     );

  //     // 4. 변경된 데이터를 적용한다.
  //     state = pState.copyWith(
  //       data: pState.data,
  //     );

  //     // 5. 서버에 좋아요를 요청한다.
  //     // 요청 시 현재의 상태가 0 -> 1 이면 좋아요를 생성
  //     // 요청 시 현재의 상태가 1 -> 0 이면 좋아요를 삭제
  //     EasyDebounce.debounce(
  //       'debounce/like/$commentId',
  //       const Duration(seconds: 1),
  //       () => pState.data[selecteComment].isLike
  //           ? repository.createchatLike(id: commentId)
  //           : repository.deletechatLike(id: commentId),
  //     );
  //   }
  // }

  // Future<void> deleteComment({
  //   required String commentId,
  // }) async {
  //   if (state is CursorPagination) {
  //     var pState = state as CursorPagination<chatModel>;

  //     // 1. 선택된 comment를 찾는다.
  //     final selecteComment = pState.data.indexWhere(
  //       (element) => element.id == commentId,
  //     );

  //     // 2. 만약 선택된 comment가 없다면 그냥 리턴
  //     if (selecteComment == -1) {
  //       return;
  //     }

  //     // 3. 선택된 comment가 있다면 해당 데이터를 변경한다.
  //     pState.data.removeAt(selecteComment);

  //     // 4. 변경된 데이터를 적용한다.
  //     state = pState.copyWith(
  //       data: pState.data,
  //     );

  //     // 5. 서버에 삭제 요청을 보낸다.
  //     await repository.deleteComment(id: commentId);
  //   }
  //   return;
  // }

  // Future<void> patchComment({
  //   required String commentId,
  //   required String content,
  // }) async {
  //   if (state is CursorPagination) {
  //     var pState = state as CursorPagination<chatModel>;

  //     // 1. 선택된 comment를 찾는다.
  //     final selecteComment = pState.data.indexWhere(
  //       (element) => element.id == commentId,
  //     );

  //     // 2. 만약 선택된 comment가 없다면 그냥 리턴
  //     if (selecteComment == -1) {
  //       return;
  //     }

  //     // 3. 선택된 comment가 있다면 해당 데이터를 변경한다.
  //     pState.data[selecteComment] = pState.data[selecteComment].copyWith(
  //       content: content,
  //     );

  //     // 4. 변경된 데이터를 적용한다.
  //     state = pState.copyWith(
  //       data: pState.data,
  //     );

  //     // 5. 서버에 삭제 요청을 보낸다.
  //     await repository.patchComment(
  //       id: commentId,
  //       content: chatContentReqModel(
  //         content: content,
  //       ),
  //     );
  //   }
  //   return;
  // }
}
