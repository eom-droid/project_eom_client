import 'dart:async';

import 'package:client/chat/model/chat_message_model.dart';
import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/provider/chat_provider.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/common/socketio/socketio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref: ref,
  );
});

class ChatRepository {
  late final SocketIO socket;
  final Ref ref;
  final chatResponseStream = StreamController<ChatResponseModel>();
  ChatRepository({
    required this.ref,
  });

  init({
    bool reInit = false,
  }) async {
    socket = SocketIO(
      accessToken:
          (await ref.read(secureStorageProvider).read(key: ACCESS_TOKEN_KEY))!,
      onError: ref.read(chatProvider.notifier).onSocketError,
      url: "${dotenv.env['CHAT_SERVER_IP']!}/chat",
      path: '/project-eom/chat-server',
    );
    await socket.socketInit(reInit: reInit);
    // socketOnAll();
  }

  Future<List<ChatModel>?> getChatRoom() async {
    final Completer<List<ChatModel>?> completer = Completer();

    socket.emitWithAck("getChatRoom", {}, (resp) {
      print(resp);
      final status = resp['status'];
      if (status >= 200 && status < 300) {
        final List<ChatModel> chatRooms = [];
        for (final chatRoom in resp['data']) {
          chatRooms.add(ChatModel.fromJson(chatRoom));
        }
        completer.complete(chatRooms);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  Future<CursorPagination<ChatMessageModel>?> paginateMessage({
    required PaginationParams paginationParams,
    required String roomId,
  }) {
    final Completer<CursorPagination<ChatMessageModel>?> completer =
        Completer();

    socket.emitWithAck("getMessages", {
      "roomId": roomId,
      "paginationParams": paginationParams.toJson(),
    }, (resp) {
      final status = resp['status'];

      if (status >= 200 && status < 300) {
        final data = resp['data'];

        final result = CursorPagination.fromJson(data, (_) {
          final temp = _ as Map<String, dynamic>;
          return ChatMessageModel.fromJson(temp);
        });

        completer.complete(result);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  reconnect({
    required String accessToken,
    dynamic Function(dynamic)? onConnectCallback,
  }) {
    socketOffAll();
    // socket.reInit(accessToken);
    socketOnAll();
    // socket.connect(onConnectCallback: onConnectCallback);
  }

  test() {
    // socket.emitWithAck("test", "1111", a);
  }

  void socketOffAll() {
    socket.off("getChatRoomsRes", _getChatRoomsRes);
    socket.off("getMessageRes", _getMessageResListener);
    socket.off("paginateMessageRes", _paginateMessageResListener);
    socket.off("enterRoomRes", _enterRoomResListener);
    socket.off("sendMessageRes", _sendMessageRes);
  }

  void socketOnAll() {
    socket.on('getChatRoomsRes', _getChatRoomsRes);
    socket.on('getMessageRes', _getMessageResListener);
    socket.on('paginateMessageRes', _paginateMessageResListener);
    socket.on('enterRoomRes', _enterRoomResListener);
    socket.on('sendMessageRes', _sendMessageRes);
  }

  void enterRoom(String roomId) {
    socket.emit("enterRoomReq", {
      "roomId": roomId,
    });
  }

  void leaveRoom(String roomId) {
    socket.emit("leaveRoomReq", {
      "roomId": roomId,
    });
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

  void _getMessageResListener(dynamic data) {
    print("[SocketIO] getMessageRes");
    chatResponseStream.sink.add(
      ChatResponseModel(
        state: ChatResponseState.getMessageRes,
        data: data,
      ),
    );
  }

  // join 시에도 이 경로를 통해 들어옴

  void _paginateMessageResListener(dynamic data) {
    print("[SocketIO] paginateMessageRes");
    chatResponseStream.sink.add(
      ChatResponseModel(
        state: ChatResponseState.paginateMessageRes,
        data: data,
      ),
    );
  }

  // 여기는 사실상 에러처리함
  void _enterRoomResListener(dynamic data) {
    print("[SocketIO] enterRoomRes");
    chatResponseStream.sink.add(
      ChatResponseModel(
        state: ChatResponseState.enterRoomRes,
        data: data,
      ),
    );
  }

  // 여기는 사실상 에러처리함
  void _sendMessageRes(dynamic data) async {
    print("[SocketIO] sendMessageRes");
    chatResponseStream.sink.add(
      ChatResponseModel(
        state: ChatResponseState.sendMessageRes,
        data: data,
      ),
    );
  }

  void _getChatRoomsRes(dynamic data) {
    print("[SocketIO] getChatRoomsRes");
    chatResponseStream.sink.add(
      ChatResponseModel(
        state: ChatResponseState.getChatRoomsRes,
        data: data,
      ),
    );
  }
}
