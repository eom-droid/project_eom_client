import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/repository/chat_room_repository.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/socketio/socketio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomProvider =
    StateNotifierProvider<ChatRoomStateNotifier, CursorPaginationBase>((ref) {
  final chatRoomRepository = ref.watch(chatRoomRepositoryProvider);
  return ChatRoomStateNotifier(
    repository: chatRoomRepository,
    ref: ref,
  );
});

final chatRoomStreamProvider = StreamProvider<ChatResponseModel>((ref) {
  final chatRoomRepository = ref.read(chatRoomRepositoryProvider);
  return chatRoomRepository.chatRoomResponse.stream;
});

// 일단 임시로 Cursorpagination 을 사용하자
// 그리고 Cursorpagina

class ChatRoomStateNotifier extends StateNotifier<CursorPaginationBase> {
  final ChatRoomRepository repository;
  final StateNotifierProviderRef ref;

  ChatRoomStateNotifier({
    required this.repository,
    required this.ref,
  }) : super(CursorPaginationLoading()) {
    ref.listen(chatRoomStreamProvider, (AsyncValue<dynamic>? previous,
        AsyncValue<ChatResponseModel> next) async {
      try {
        // getChatRoomsRes 에 대한 처리만 담겨있음
        if (next.value == null) {
          throw Exception('채팅방을 불러오는데 실패하였습니다.');
        }
        if (next.value!.state != ChatResponseState.getChatRoomsRes) {
          throw Exception('채팅방을 불러오는데 실패하였습니다.');
        }
        final resObj = next.value!.data;

        final statusCode = resObj['status'];

        // getChatRoomsRes는 401 받기는 하지만 결국에는 error로 인한 socketiio 재연결 시도를 진행해야함
        // if (statusCode == 401) {
        //   ref.read(socketIOProvider).initAccessToken;
        // }

        if (statusCode >= 200 && statusCode < 300) {
          final chatRooms = resObj['data'] as List<dynamic>;

          final chatRoomModels =
              chatRooms.map((e) => ChatRoomModel.fromJson(e)).toList();

          state = CursorPagination<ChatRoomModel>(
            meta: CursorPaginationMeta(
              hasMore: false,
              count: chatRoomModels.length,
            ),
            data: chatRoomModels,
          );
        } else {
          throw Exception('채팅방을 불러오는데 실패하였습니다.');
        }
      } catch (error) {
        print(error);
        state = CursorPaginationError(message: '채팅방을 불러오는데 실패하였습니다.');
      }
    });
  }

  ChatRoomModel? getChatRoomInfo(String roomId) {
    final chatRoomState = state;
    if (chatRoomState is CursorPagination) {
      final chatRoom = chatRoomState.data.firstWhere((e) => e.id == roomId);
      return chatRoom;
    } else {
      return null;
    }
  }

  void setError(String eventName) {
    state = CursorPaginationError(message: eventName);
  }

  void reconnect() {
    ref.read(socketIOProvider).socketInit(
          getNewAccessToken: true,
        );
  }
}
