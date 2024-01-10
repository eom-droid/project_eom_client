import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  static const routeName = 'chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late IO.Socket socket;

  // app의 상태값이 변경될 때 호출되는 함수
  // AppLifecycleState.puased : 앱이 백그라운드로 전환
  // AppLifecycleState.resumed : 앱이 포그라운드로 전환
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      socket.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      socket.connect();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    initSocket();
    super.initState();
  }

  initSocket() {
    String ip = dotenv.env['CHAT_SERVER_IP']!.toString();
    socket = IO.io("http://$ip", <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'path': '/socket.io',
    });
    socket.connect();
    socket.onConnect((data) {
      print('Connection established');
    });

    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
