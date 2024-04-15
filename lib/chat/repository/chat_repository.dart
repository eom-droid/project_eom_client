import 'dart:async';

import 'package:client/chat/const/chat_default.dart';
import 'package:client/chat/model/chat_message_model.dart';
import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_response_model.dart';
import 'package:client/chat/provider/chat_provider.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/common/socketio/socketio.dart';
import 'package:client/user/provider/user_provider.dart';
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

  Future<bool> init({
    bool reInit = false,
  }) async {
    String? accessToken;
    try {
      if (reInit) {
        accessToken = await ref
            .read(userProvider.notifier)
            .getAccessTokenByRefreshToken();
      } else {
        throw Exception("reInit is false");
      }
    } catch (e) {
      accessToken =
          (await ref.read(secureStorageProvider).read(key: ACCESS_TOKEN_KEY));
    }

    if (accessToken == null) {
      return false;
    }

    socket = SocketIO(
      accessToken: accessToken,
      onError: ref.read(chatProvider.notifier).onSocketError,
      url: "${dotenv.env['CHAT_SERVER_IP']!}/chat",
      path: '/project-eom/chat-server',
    );
    await socket.socketInit(reInit: reInit);
    socketOnAll();
    return true;
  }

  Future<List<ChatModel>?> getChatRoom() async {
    final Completer<List<ChatModel>?> completer = Completer();

    socket.emitWithAck(SocketEvent.getChatRoom, {}, (resp) {
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

    socket.emitWithAck(SocketEvent.getMessages, {
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
    // socketOffAll();
    // socket.reInit(accessToken);
    // socketOnAll();
    // socket.connect(onConnectCallback: onConnectCallback);
  }

  void socketOnAll() {
    socket.on(SocketEvent.newMessage, _newMessage);
    socket.on(SocketEvent.enterRoomOtherUser, _enterRoomOtherUser);
  }

  void socketOffAll() {
    socket.off(SocketEvent.newMessage, _newMessage);
    socket.off(SocketEvent.enterRoomOtherUser, _enterRoomOtherUser);
  }

  _newMessage(dynamic data) {
    print("[SocketIO] newMessage");
    chatResponseStream.sink.add(
      ChatResponseModel(
        event: SocketEvent.newMessage,
        data: data,
      ),
    );
  }

  _enterRoomOtherUser(dynamic data) {
    print("[SocketIO] enterRoomOtherUser");
    chatResponseStream.sink.add(
      ChatResponseModel(
        event: SocketEvent.enterRoomOtherUser,
        data: data,
      ),
    );
  }

  Future<String?> enterRoom(String roomId) {
    final Completer<String?> completer = Completer();

    socket.emitWithAck(SocketEvent.enterRoom, {
      "roomId": roomId,
    }, (resp) {
      final status = resp['status'];

      if (status >= 200 && status < 300) {
        final data = resp['data'];
        completer.complete(data["lastChatId"]);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  // 실패 시 처리만 진행하면됨
  // 성공 시의 처리는 위 newMessage에서 진행함
  Future<String?> postMessage({
    required String roomId,
    required String content,
    required String tempMessageId,
    required String accessToken,
  }) {
    final Completer<String?> completer = Completer();

    socket.emitWithAck(SocketEvent.postMessage, {
      "roomId": roomId,
      "content": content,
      "tempMessageId": tempMessageId,
      "accessToken": accessToken
    }, (resp) {
      final status = resp['status'];

      if (status >= 200 && status < 300) {
        final error = resp['message'] ?? "";
        completer.complete(error);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  void leaveRoom(String roomId) {
    socket.emit(SocketEvent.leaveRoom, {
      "roomId": roomId,
    });
  }

  // void sendMessage({
  //   required String roomId,
  //   required String content,
  //   required String tempMessageId,
  //   required String accessToken,
  //   required String createdAt,
  // }) {
  //   socket.emit("sendMessageReq", {
  //     "accessToken": "Bearer $accessToken",
  //     "roomId": roomId,
  //     "content": content,
  //     "id": tempMessageId,
  //     "createdAt": createdAt,
  //     "tempMessageId": tempMessageId,
  //   });
  // }
}
