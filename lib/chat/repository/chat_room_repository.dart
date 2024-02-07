import 'dart:async';

import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/common/socketio/socketio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  final socketIO = ref.read(socketIOProvider);

  return ChatRoomRepository(
    socket: socketIO,
  );
});

class ChatRoomRepository {
  final SocketIO socket;
  final chatRoomResponse = StreamController<ChatResponseModel>();
  ChatRoomRepository({
    required this.socket,
  }) : super() {
    init();
  }

  void onGetChatRoomsRes() async {
    socket.on('getChatRoomsRes', (data) {
      chatRoomResponse.sink.add(
        ChatResponseModel(
          state: ChatResponseState.getChatRoomsRes,
          data: data,
        ),
      );
    });
  }

  init() {
    onGetChatRoomsRes();
  }
}
