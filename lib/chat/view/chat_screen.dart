import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/provider/chat_room_provider.dart';
import 'package:client/chat/view/chat_detail_screen.dart';
import 'package:client/common/components/cursor_pagination_error_comp.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerWidget {
  static String get routeName => 'chat';

  const ChatScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(chatRoomProvider);
    ChatRoomModel? room;
    print("buuild ChatScreen roomState: $roomState");
    if (roomState is CursorPagination<ChatRoomModel>) {
      room = roomState.data[0];
    }

    // TODO : 나중에 CusrsorPaginationError 상태에 따른 분기가 필요함

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
        child: room != null
            ? GestureDetector(
                onTap: () {
                  context.pushNamed(
                    ChatDetailScreen.routeName,
                    pathParameters: {
                      'rid': room!.id.toString(),
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
            : roomState is CursorPaginationError
                ?
                // 에러 상태일 때
                CursorPaginationErrorComp(
                    state: roomState,
                    onRetry: () {
                      ref.read(chatRoomProvider.notifier).reconnect();
                    },
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
