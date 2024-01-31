import 'dart:async';

import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/socketio/socketio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider =
    Provider.family<ChatRepository, String>((ref, roomId) {
  final SocketIO socketIO = ref.read(socketIOProvider);
  return ChatRepository(
    socket: socketIO,
    roomId: roomId,
  );
});

class ChatRepository {
  final SocketIO socket;
  final String roomId;
  final chatResponse = StreamController<ChatResponseModel>();
  ChatRepository({
    required this.socket,
    required this.roomId,
  });

  void paginate({
    required PaginationParams paginationParams,
    required String accessToken,
  }) {
    socket.emit("paginateMessageReq", {
      "roomId": roomId,
      "paginationParams": paginationParams.toJson(),
      "accessToken": "Bearer $accessToken",
    });
    return;
  }

  void joinRoom({
    required String accessToken,
  }) {
    socket.emit("joinRoomReq", {
      "accessToken": "Bearer $accessToken",
      "roomId": roomId,
    });
    return;
  }

  void postMessage({
    required String roomId,
    required String content,
    required String tempMessageId,
    required String accessToken,
    required String createdAt,
  }) {
    socket.emit("postMessageReq", {
      "accessToken": "Bearer $accessToken",
      // "roomId": roomId,
      "content": content,
      "id": tempMessageId,
      "createdAt": createdAt,
      "tempMessageId": tempMessageId,
    });
  }

  //
  void onGetMessageRes() async {
    socket.on('getMessageRes', (data) {
      print("[SocketIO] getMessageRes");
      chatResponse.sink.add(
        ChatResponseModel(
          state: ChatResponseState.getMessageRes,
          data: data,
        ),
      );
    });
  }

  // join 시에도 이 경로를 통해 들어옴
  void onPaginateMessageRes() async {
    socket.on('paginateMessageRes', (data) {
      print("[SocketIO] paginateMessageRes");
      chatResponse.sink.add(
        ChatResponseModel(
          state: ChatResponseState.paginateMessageRes,
          data: data,
        ),
      );
    });
  }

  // 여기는 사실상 에러처리함
  void onJoinRoomRes() async {
    socket.on('joinRoomRes', (data) {
      print("[SocketIO] joinRoomRes");
      chatResponse.sink.add(
        ChatResponseModel(
          state: ChatResponseState.joinRoomRes,
          data: data,
        ),
      );
    });
  }

  // 여기는 사실상 에러처리함
  void onPostMessageRes() async {
    socket.on('postMessageRes', (data) {
      print("[SocketIO] postMessageRes");
      chatResponse.sink.add(
        ChatResponseModel(
          state: ChatResponseState.postMessageRes,
          data: data,
        ),
      );
    });
  }
}
