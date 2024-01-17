import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:flutter/material.dart';

class ChatRoomListScreen extends StatefulWidget {
  static String get routeName => 'chatRoomList';

  const ChatRoomListScreen({
    super.key,
  });

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
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
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width / 1.5,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
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
                    // profileImage를 원으로 자르기
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 6,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(2), // Border radius
                        child: ClipOval(
                          child: Image.network(
                            'https://picsum.photos/250?image=9',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      '메시지4648684w46wea684wea46aef468',
                      style: TextStyle(
                        color: INPUT_BG_COLOR,
                        fontSize: 14.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                top: 0,
                right: 0,
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
                      Radius.circular(8.0),
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: const Text(
                    '10',
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
      ),
    );
  }
}
