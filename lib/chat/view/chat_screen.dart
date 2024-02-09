import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/provider/chat_provider.dart';
import 'package:client/chat/provider/chat_room_provider.dart';
import 'package:client/chat/view/chat_detail_screen.dart';
import 'package:client/common/components/cursor_pagination_error_comp.dart';
import 'package:client/common/components/cursor_pagination_loading_comp.dart';
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
    ChatRoomModel? room;
    final roomState = ref.watch(chatRoomProvider);
    final hasRoom = roomState is CursorPagination<ChatRoomModel> &&
        roomState.data.isNotEmpty;
    if (hasRoom) {
      room = roomState.data[0];
    }

    final chatState = hasRoom ? ref.watch(chatProvider(room!.id)) : null;

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
      child: loadBody(
        state: roomState,
        ref: ref,
        chatState: chatState,
        buildContext: context,
      ),
    );
  }

  Widget loadBody({
    required CursorPaginationBase state,
    required WidgetRef ref,
    required CursorPaginationBase? chatState,
    required BuildContext buildContext,
  }) {
    // 초기 로딩
    if (state is CursorPaginationLoading) {
      return const CursorPaginationLoadingComp();
    }

    // 에러 발생 시
    if (state is CursorPaginationError) {
      return CursorPaginationErrorComp(
        state: state,
        onRetry: () {
          ref.read(chatRoomProvider.notifier).reconnect();
        },
      );
    }

    final cp = state as CursorPagination<ChatRoomModel>;
    if (cp.data.isEmpty) {
      return const Center(
        child: Text('채팅방이 없습니다.'),
      );
    }
    return _body(
      room: cp.data[0],
      chatState: chatState!,
      parentBuildContext: buildContext,
    );
  }

  _body({
    required ChatRoomModel room,
    required CursorPaginationBase chatState,
    required BuildContext parentBuildContext,
  }) {
    return Center(
        child: GestureDetector(
      onTap: () {
        parentBuildContext.pushNamed(
          ChatDetailScreen.routeName,
          pathParameters: {
            'rid': room.id.toString(),
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
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        width: MediaQuery.of(parentBuildContext).size.width / 1.5,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  // profileImage를 원으로 자르기
                  CircleAvatar(
                    radius: MediaQuery.of(parentBuildContext).size.width / 6,
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
                  const SizedBox(height: 30.0),
                  Column(
                    children: [
                      Text(
                        room.lastChat != null
                            ? room.lastChat!.content
                            : '첫 메시지를 남겨봐요!',
                        style: const TextStyle(
                          color: INPUT_BG_COLOR,
                          fontSize: 14.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Text(room.lastChat!.createdAt.toString()),
                      Text(
                        room.lastChat != null
                            ? DataUtils.timeAgoSinceDate2(
                                room.lastChat!.createdAt)
                            : '',
                        style: const TextStyle(
                          color: BODY_TEXT_COLOR,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
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
    ));
  }
}
