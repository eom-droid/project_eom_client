import 'dart:async';

import 'package:client/chat/const/chat_default.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// user가 로그인을 진행하지 않았다면 socketio통신을 진행할 수 없음
// 그리고 만약 진행했더라도 token이 만료되었다면 socketio통신을 진행할 수 없음
// final socketIOProvider = Provider<SocketIO>((ref) {
//   // 조금 위험한 코드이기는 함.....

//   final result = SocketIO(
//     ref: ref,
//   );

//   return result;
// });

// TODO : 401 auth 에러에 대한 처리 필요함
// 문제점 : 첫 socket의 init을 위해서는 secureStorage의 accessToken 값이 필요함
// 가져오는데 비동기로 진행할 수가 없음.....
// 근데 contructor라서 이거 가능할지가 모르겠네.......
class SocketIO {
  late IO.Socket socket;
  String accessToken;
  Function(dynamic) onError;
  final String url;
  final String path;

  SocketIO({
    required this.accessToken,
    required this.onError,
    required this.url,
    required this.path,
  });

  Future<void> socketInit({
    bool reInit = false,
  }) async {
    if (reInit) {
      socket.dispose();
    }
    // 이거 중요한 Completer가 void로 설정되어있지 않으면 작동이 안됨..........
    final Completer<void> completer = Completer();
    socket = IO.io(
      url,
      IO.OptionBuilder().disableAutoConnect().build(),
    );
    socket.io.options = {
      'path': path,
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'authorization': 'Bearer $accessToken'},
    };

    socket.onError(onError);
    socket.connect();

    socket.on(SocketEvent.connected.value, (data) {
      completer.complete();
      socket.off(SocketEvent.connected.value);
    });
    return completer.future;
  }

  Future<bool> _socketConnected() async {
    // 연결되지 않은 상태에서 요청을 보내려고 할 때, 100ms 간격으로 20번 재시도
    for (var i = 0; i < 20; i++) {
      if (socket.connected) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  on(SocketEvent eventName, Function(dynamic) callback) {
    print('[SocketIO] Event Listen: $eventName');
    socket.on(eventName.value, callback);
  }

  off(SocketEvent eventName, Function(dynamic) callback) {
    print('[SocketIO] Event Off: $eventName');
    socket.off(eventName.value, callback);
  }

  Future<void> emit(SocketEvent eventName, dynamic data) async {
    if (!socket.connected) {
      final result = await _socketConnected();
      if (!result) throw Exception('SocketIO 연결 실패');
    }
    // await Future.delayed(const Duration(milliseconds: 1000));
    print('[SocketIO] Event Emitted: $eventName, Data: $data');
    socket.emit(eventName.value, data);
    return;
  }

  Future<void> emitWithAck(
    SocketEvent eventName,
    dynamic data,
    Function? ack,
  ) async {
    if (!socket.connected) {
      final result = await _socketConnected();
      if (!result) throw Exception('SocketIO 연결 실패');
    }
    // await Future.delayed(const Duration(milliseconds: 1000));
    print('[SocketIO] Event Emitted: $eventName, Data: $data');
    socket.emitWithAck(eventName.value, data, ack: ack);
    return;
  }
}
