import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/model/web_socket_model.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends ConsumerStatefulWidget {
  static const routeName = 'chat';
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  late IO.Socket socket;

  // app의 상태값이 변경될 때 호출되는 함수
  // AppLifecycleState.puased : 앱이 백그라운드로 전환
  // AppLifecycleState.resumed : 앱이 포그라운드로 전환
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      socket.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      socket.connect();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initSocket();
    super.initState();
  }

  initSocket() async {
    final storage = ref.read(secureStorageProvider);
    String ip = dotenv.env['CHAT_SERVER_IP']!.toString();

    String token = (await storage.read(key: ACCESS_TOKEN_KEY) ?? '');

    socket = IO.io(
      "http://$ip/room",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setPath('/project-eom/chat-server')
          .setExtraHeaders({
            // 첫 연결 시 쿠키을 헤더에 담아서 보낸다.
            'authorization': 'Bearer $token',
          })
          .build(),
    );

    socket.connect();

    // socket.onConnect((data) {
    //   // send message
    // });
    socket.on(
      "/",
      (data) {
        final shit = parseResponse<ChatRoomModel>(
          data,
          ChatRoomModel.fromObject,
        );
        print(shit);

        // TODO : data를 받았을때 status code에 따라서 분기처리 401 시 재시도
      },
    );

    // socket.on("message", (data) => print(data));

    socket.onDisconnect((_) => print(_));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
  }

  @override
  void dispose() {
    if (!socket.disconnected) {
      socket.disconnect();
      socket.dispose();
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
