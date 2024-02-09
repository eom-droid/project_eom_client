import 'dart:async';

import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/socketio/socketio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider =
    Provider.family.autoDispose<ChatRepository, String>((ref, roomId) {
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

  void socketOffAll() {
    socket.off("getMessageRes", _getMessageResListener);
    socket.off("paginateMessageRes", _paginateMessageResListener);
    socket.off("enterRoomRes", _enterRoomResListener);
    socket.off("sendMessageRes", _sendMessageRes);
  }

  void paginate({
    required PaginationParams paginationParams,
  }) {
    socket.emit("paginateMessageReq", {
      "roomId": roomId,
      "paginationParams": paginationParams.toJson(),
    });
    return;
  }

  void enterRoom() {
    socket.emit("enterRoomReq", {
      "roomId": roomId,
    });
    return;
  }

  void leaveRoom() {
    socket.emit("leaveRoomReq", {
      "roomId": roomId,
    });
    return;
  }

  void sendMessage({
    required String roomId,
    required String content,
    required String tempMessageId,
    required String accessToken,
    required String createdAt,
  }) {
    socket.emit("sendMessageReq", {
      "accessToken": "Bearer $accessToken",
      "roomId": roomId,
      "content": content,
      "id": tempMessageId,
      "createdAt": createdAt,
      "tempMessageId": tempMessageId,
    });
  }

  //
  void onGetMessageRes() async {
    socket.on('getMessageRes', _getMessageResListener);
  }

  void _getMessageResListener(dynamic data) {
    print("[SocketIO] getMessageRes");
    chatResponse.sink.add(
      ChatResponseModel(
        state: ChatResponseState.getMessageRes,
        data: data,
      ),
    );
  }

  // join 시에도 이 경로를 통해 들어옴
  void onPaginateMessageRes() async {
    socket.on('paginateMessageRes', _paginateMessageResListener);
  }

  void _paginateMessageResListener(dynamic data) {
    print("[SocketIO] paginateMessageRes");
    chatResponse.sink.add(
      ChatResponseModel(
        state: ChatResponseState.paginateMessageRes,
        data: data,
      ),
    );
  }

  // 여기는 사실상 에러처리함
  void onenterRoomRes() async {
    socket.on('enterRoomRes', _enterRoomResListener);
  }

  void _enterRoomResListener(dynamic data) {
    print("[SocketIO] enterRoomRes");
    chatResponse.sink.add(
      ChatResponseModel(
        state: ChatResponseState.enterRoomRes,
        data: data,
      ),
    );
  }

  // 여기는 사실상 에러처리함
  void onsendMessageRes() async {
    socket.on('sendMessageRes', _sendMessageRes);
  }

  void _sendMessageRes(dynamic data) async {
    print("[SocketIO] sendMessageRes");
    chatResponse.sink.add(
      ChatResponseModel(
        state: ChatResponseState.sendMessageRes,
        data: data,
      ),
    );
  }
}
