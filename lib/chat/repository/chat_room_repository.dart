import 'dart:async';

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
  final chatRoomResponse = StreamController<dynamic>();
  ChatRoomRepository({
    required this.socket,
  }) : super() {
    onGetChatRoomsRes();
  }

  void onGetChatRoomsRes() async {
    socket.on('getChatRoomsRes', (data) {
      chatRoomResponse.sink.add(data);
    });
  }
}
