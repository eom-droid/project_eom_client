import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/model/web_socket_model.dart';
import 'package:client/chat/view/chat_detail_screen.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chat';

  const ChatScreen({
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  WebSocketModel<ChatRoomModel>? rooms;
  late IO.Socket socket;

  @override
  void initState() {
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

    socket.on(
      "/",
      (data) {
        final shit = parseResponse<ChatRoomModel>(
          data,
          ChatRoomModel.fromObject,
        );
        if (shit is WebSocketModel) {
          setState(() {
            rooms = shit as WebSocketModel<ChatRoomModel>;
          });
        }
        // TODO : data를 받았을때 status code에 따라서 분기처리 401 시 재시도
      },
    );
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) { })

    // socket.on("message", (data) => print(data));

    socket.onDisconnect((_) => print(_));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
  }

  @override
  void dispose() {
    print('???????????');
    if (!socket.disconnected) {
      socket.disconnect();
      // socket.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: BACKGROUND_BLACK,
      appBar: AppBar(
        title: const Text(
          "Direct Message",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'sabreshark',
            fontSize: 20.0,
          ),
        ),
        backgroundColor: BACKGROUND_BLACK,
      ),
      child: Center(
        child: rooms != null
            ? GestureDetector(
                onTap: () {
                  context.pushNamed(
                    ChatDetailScreen.routeName,
                    pathParameters: {
                      'rid': rooms!.data[0].id.toString(),
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    // shadow
                    borderRadius: BorderRadius.circular(10.0),
                    color: BACKGROUND_BLACK,
                    border: Border.all(
                      color: PRIMARY_COLOR,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.5,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 30.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '타이틀',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            // profileImage를 원으로 자르기
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 6,
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(2), // Border radius
                                child: ClipOval(
                                  child: Image.network(
                                    'https://picsum.photos/250?image=9',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            const Text(
                              '메시지4648684w46wea684wea46aef468',
                              style: TextStyle(
                                color: INPUT_BG_COLOR,
                                fontSize: 14.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              DataUtils.timeAgoSinceDate2(
                                DateTime(
                                  2024,
                                  1,
                                  17,
                                  10,
                                  10,
                                  10,
                                  10,
                                  10,
                                ),
                              ),
                              style: const TextStyle(
                                color: BODY_TEXT_COLOR,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 7,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 8,
                            left: 8,
                            right: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(
                              Radius.circular(14.0),
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: const Text(
                            '10+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
