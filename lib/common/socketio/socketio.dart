import 'dart:async';

import 'package:client/chat/provider/chat_room_provider.dart';
import 'package:client/user/model/user_with_token_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// user가 로그인을 진행하지 않았다면 socketio통신을 진행할 수 없음
// 그리고 만약 진행했더라도 token이 만료되었다면 socketio통신을 진행할 수 없음
final socketIOProvider = Provider<SocketIO>((ref) {
  // 조금 위험한 코드이기는 함.....

  final result = SocketIO(
    ref: ref,
  );

  return result;
});

// TODO : 401 auth 에러에 대한 처리 필요함
// 문제점 : 첫 socket의 init을 위해서는 secureStorage의 accessToken 값이 필요함
// 가져오는데 비동기로 진행할 수가 없음.....
// 근데 contructor라서 이거 가능할지가 모르겠네.......
class SocketIO {
  late IO.Socket? socket;

  final ProviderRef ref;

  SocketIO({
    required this.ref,
  }) : super() {
    socketInit();
  }

  socketInit({
    bool getNewAccessToken = false,
  }) async {
    // 만약 socket이 이미 연결되어있었다면, 연결을 끊고 다시 연결한다.
    if (socket != null) {
      socket!.dispose();
    }
    String accessToken = "";
    if (getNewAccessToken) {
      // 만약 accessToken이 만료되었을경우
      accessToken =
          await ref.read(userProvider.notifier).getAccessTokenByRefreshToken();
    } else {
      // 만약 accessToken이 만료되지 않았을 경우
      final user = ref.read(userProvider) as UserWithTokenModel;
      accessToken = user.token.accessToken;
    }

    socket = IO.io(
      'http://localhost:3002/chat',
      IO.OptionBuilder()
          .setPath("/project-eom/chat-server")
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            // 첫 연결 시 쿠키을 헤더에 담아서 보낸다.
            'authorization': 'Bearer $accessToken',
          })
          .build(),
    );

    // 연결 실패시의 이벤트 핸들러
    socket!.onError((error) {
      ref.read(chatRoomProvider.notifier).setError("SocketIO 연결 실패");
      // TODO : 에러 처리
    });

    // 연결 시작
    socket!.connect();
  }

  Future<bool> connect() async {
    // 연결되지 않은 상태에서 요청을 보내려고 할 때, 100ms 간격으로 20번 재시도
    for (var i = 0; i < 20; i++) {
      if (socket != null && socket!.connected) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  on(String eventName, Function(dynamic) callback) {
    if (socket == null) {
      throw Exception('SocketIO 연결이 되어있지 않습니다.');
    }
    print('[SocketIO] Event Listen: $eventName');
    socket!.on(eventName, callback);
  }

  Future<void> emit(String eventName, dynamic data) async {
    if (socket == null || !socket!.connected) {
      final result = await connect();
      if (!result) throw Exception('SocketIO 연결 실패');
    }
    print('[SocketIO] Event Emitted: $eventName, Data: $data');
    socket!.emit(eventName, data);
    return;
  }
}

// class WebSocketInterceptor {
//   void onRequest(String eventName, List<dynamic> args) {
//     print('[SocketIO] Event Requested: $eventName, Args: $args');
//   }

//   void onResponse(String eventName, List<dynamic> args) {
//     print('[SocketIO] Event Received: $eventName, Args: $args');
//   }
// }
