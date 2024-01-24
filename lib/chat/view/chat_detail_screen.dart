import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'chatDetail';
  final String id;
  const ChatDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with WidgetsBindingObserver {
  final TextEditingController _textEditingController = TextEditingController();

  // app의 상태값이 변경될 때 호출되는 함수
// AppLifecycleState.puased : 앱이 백그라운드로 전환
  // AppLifecycleState.resumed : 앱이 포그라운드로 전환
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused) {
  //     socket.disconnect();
  //   } else if (state == AppLifecycleState.resumed) {
  //     socket.connect();
  //   }
  // }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initSocket();
    super.initState();
  }

  initSocket() async {
    final storage = ref.read(secureStorageProvider);

    token = (await storage.read(key: ACCESS_TOKEN_KEY) ?? '');

    // socket = IO.io(
    //   "http://$ip/chat",
    //   IO.OptionBuilder()
    //       .setTransports(['websocket'])
    //       .disableAutoConnect()
    //       .setPath('/project-eom/chat-server')
    //       .build(),
    // );
    // socket.connect();

    // socket.onConnect((data) {
    //   socket.emit('join', {
    //     "roomId": "wefwef",
    //   });
    //   print("-----------------");
    // });
    widget.socket.emit("join", {
      "roomId": widget.id,
    });

    widget.socket.on("join", (data) {
      print(data);
    });

    // widget.socket.onDisconnect((_) => print(_));
    // widget.socket.onConnectError((err) => print(err));
    // widget.socket.onError((err) => print(err));
  }

  @override
  void dispose() {
    // if (!socket.disconnected) {
    //   socket.disconnect();
    //   socket.dispose();
    // }

    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isFullScreen: true,
      backgroundColor: BACKGROUND_BLACK,
      appBar: AppBar(
        backgroundColor: BACKGROUND_BLACK,
        // leadingWidth: 40,
        titleSpacing: 0,
        centerTitle: false,
        title: const Text(
          '타이틀',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            ListView.separated(
              itemCount: 12,
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.white,
                  height: 1,
                );
              },
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이름',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '메세지',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        '시간',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: BACKGROUND_LIGHT_BLACK,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: _textEditingController,
                        underline: false,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    if (_textEditingController.text.isNotEmpty)
                      InkWell(
                        onTap: () {
                          onSendMessage(_textEditingController.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          color: PRIMARY_COLOR,
                          child: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onSendMessage(String content) {
    if (content.trim() != '') {
      setState(() {
        _textEditingController.clear();
      });
      var data = {
        'access-token': 'Bearer $token',
        'roomId': widget.id,
        'content': content,
      };
      widget.socket.emit('message', data);
    }
  }
}
