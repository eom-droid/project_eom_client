import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/provider/chat_provider.dart';
import 'package:client/chat/provider/chat_room_provider.dart';
import 'package:client/common/components/cursor_pagination_error_comp.dart';
import 'package:client/common/components/cursor_pagination_loading_comp.dart';
import 'package:client/common/components/custom_circle_avatar.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/const/setting.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
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
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();

    // Paginating 시, 스크롤이 최하단에 닿았을 때 추가 데이터를 가져오기 위한 리스너
    controller = ScrollController();
    controller.addListener(listener);
    // 앱 상태 변경 시 트리거
    WidgetsBinding.instance.addObserver(this);
  }

  void listener() {
    if (controller.position.maxScrollExtent == 0 ||
        controller.position.maxScrollExtent <= GAP_WHEN_PAGINATE) return;
    if (controller.offset >
        controller.position.maxScrollExtent - GAP_WHEN_PAGINATE) {
      ref.read(chatProvider(widget.id).notifier).paginate(
            fetchMore: true,
          );
    }
  }

  @override
  void deactivate() {
    print("deactivate");
    // deactivate 이후에는 ref를 read해올수 없음
    ref.read(chatProvider(widget.id).notifier).leaveRoom();
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state : $state');
    if (state == AppLifecycleState.resumed) {
      ref.read(chatProvider(widget.id).notifier).reJoinRoom();
    } else if (state == AppLifecycleState.paused) {
      ref.read(chatProvider(widget.id).notifier).leaveRoom();
    }
  }

  Widget loadBody({
    required ChatPagination state,
    required ChatRoomModel? room,
    required UserModel me,
  }) {
    final chatState = state.state;
    // 에러 발생 시
    if (chatState is CursorPaginationError) {
      return CursorPaginationErrorComp(
        state: chatState,
        onRetry: () {
          ref.read(chatProvider(widget.id).notifier).paginate(
                forceRefetch: true,
              );
        },
      );
    }

    if (room == null) {
      return const Center(
        child: Text('채팅방이 존재하지 않습니다.'),
      );
    }

    // CursorPagination
    // CursorPaginationFetchMore
    // CursorPaginationRefetching

    // 초기 로딩
    if (chatState is CursorPaginationLoading ||
        chatState is! CursorPagination<ChatModel>) {
      return const CursorPaginationLoadingComp();
    }

    return _body(
      chatState: state,
      room: room,
      me: me,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.id));
    final room = ref.read(chatRoomProvider.notifier).getChatRoomInfo(widget.id);
    final me = ref.read(userProvider) as UserModel;
    return DefaultLayout(
      isFullScreen: true,
      backgroundColor: BACKGROUND_BLACK,
      appBar: AppBar(
        backgroundColor: BACKGROUND_BLACK,
        // leadingWidth: 40,
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          room == null ? '채팅방 미존재' : room.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: loadBody(
        room: room,
        me: me,
        state: chatState,
      ),
    );
  }

  Widget _body({
    required ChatPagination chatState,
    required ChatRoomModel room,
    required UserModel me,
  }) {
    final cp = chatState.state as CursorPagination<ChatModel>;
    // final members = room.members;
    return SafeArea(
      bottom: true,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 50,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: ListView.builder(
                reverse: true,
                controller: controller,
                itemCount: cp.data.length,
                itemBuilder: (context, index) {
                  final userId = cp.data[index].userId;
                  final nextUserId = index + 1 < cp.data.length
                      ? cp.data[index + 1].userId
                      : null;
                  final previousUserId =
                      index - 1 > -1 ? cp.data[index - 1].userId : null;
                  final afterCreatedAt = index + 1 < cp.data.length
                      ? cp.data[index + 1].createdAt
                      : null;
                  final isMe = userId == me.id;
                  final user = room.members.firstWhere(
                    (element) => element.id == userId,
                  );

                  final previousCreatedAt =
                      index - 1 > -1 ? cp.data[index - 1].createdAt : null;

                  final chat = cp.data[index];

                  bool showChatTime = previousCreatedAt == null
                      ? previousUserId != userId
                      : previousUserId != userId ||
                          previousCreatedAt.day != chat.createdAt.day ||
                          previousCreatedAt.month != chat.createdAt.month ||
                          previousCreatedAt.year != chat.createdAt.year ||
                          previousCreatedAt.hour != chat.createdAt.hour ||
                          previousCreatedAt.minute != chat.createdAt.minute;

                  bool showAvatar = afterCreatedAt == null
                      ? !isMe
                      : !isMe &&
                          (nextUserId != userId ||
                              afterCreatedAt.day != chat.createdAt.day ||
                              afterCreatedAt.month != chat.createdAt.month ||
                              afterCreatedAt.year != chat.createdAt.year ||
                              afterCreatedAt.hour != chat.createdAt.hour ||
                              afterCreatedAt.minute != chat.createdAt.minute);
                  int readUserCount = chatState.memberLastReadChatMap.length;
                  chatState.memberLastReadChatMap.forEach((key, value) {
                    if (value != null) {
                      if (value.compareTo(chat.id) >= 0) {
                        readUserCount--;
                      }
                    }
                  });

                  // print(cp.data[index].id.compareTo(myLastReadChat));
                  return Column(
                    children: [
                      const SizedBox(
                        height: 7.0,
                      ),
                      SizedBox(
                        height: showAvatar ? 5 : 0,
                      ),
                      _chatDate(
                        createdAt: chat.createdAt,
                        nextCreatedAt: afterCreatedAt,
                      ),
                      if (isMe)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.12,
                            ),
                            Row(
                              children: [
                                if (chat is ChatTempModel)
                                  Transform.flip(
                                    flipX: true,
                                    child: const Icon(
                                      Icons.send,
                                      color: BODY_TEXT_COLOR,
                                      size: 12.0,
                                    ),
                                  ),
                                if (chat is ChatFailedModel)
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              backgroundColor: BACKGROUND_BLACK,
                                              content: const Text(
                                                '재전송하시겠습니까?',
                                                style: TextStyle(
                                                  color: GRAY_TEXT_COLOR,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(chatProvider(
                                                                widget.id)
                                                            .notifier)
                                                        .deleteFailedMessage(
                                                          tempMessageId: chat
                                                              .tempMessageId,
                                                        );
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    '삭제',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(chatProvider(
                                                                widget.id)
                                                            .notifier)
                                                        .resendMessage(
                                                          tempMessageId: chat
                                                              .tempMessageId,
                                                        );

                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    '재전송',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 5.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          color: BACKGROUND_LIGHT_BLACK,
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(3),
                                                child: Icon(
                                                  Icons.refresh_outlined,
                                                  color: Colors.white,
                                                  size: 11.0,
                                                ),
                                              ),
                                              const VerticalDivider(
                                                color: BACKGROUND_BLACK,
                                                thickness: 0.5,
                                                width: 0.0,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: Icon(
                                                  Icons.close_sharp,
                                                  color: Colors.red[400],
                                                  size: 12.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (chat is! ChatFailedModel)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (readUserCount > 0)
                                        Text(
                                          readUserCount.toString(),
                                          style: const TextStyle(
                                            color: PRIMARY_COLOR,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      showChatTime
                                          ? _chatTime(
                                              chat.createdAt,
                                            )
                                          : const SizedBox(
                                              width: 0,
                                            ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 9.0,
                                ),
                                decoration: BoxDecoration(
                                  color: PRIMARY_COLOR,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  chat.content,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!isMe)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showAvatar)
                              // user profile이 없는 경우는 ?로 대체

                              CustomCircleAvatar(
                                url: user.profileImg,
                              ),
                            SizedBox(
                              width: showAvatar ? 10 : 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showAvatar)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      user.nickname,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.78,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 9.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BACKGROUND_LIGHT_BLACK,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Text(
                                            chat.content,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (readUserCount > 0)
                                            Text(
                                              readUserCount.toString(),
                                              style: const TextStyle(
                                                color: PRIMARY_COLOR,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          showChatTime
                                              ? _chatTime(
                                                  chat.createdAt,
                                                )
                                              : const SizedBox(
                                                  width: 0,
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomInput(
              onSendMessage: onSendMessage,
            ),
          ),
        ],
      ),
    );
  }

  _chatTime(DateTime createdAt) {
    return Text(
      DataUtils.dateTimeToHHmm(
        createdAt,
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
    );
  }

  _chatDate({
    required DateTime createdAt,
    required DateTime? nextCreatedAt,
  }) {
    if (nextCreatedAt != null &&
        (nextCreatedAt.day != createdAt.day ||
            nextCreatedAt.month != createdAt.month ||
            nextCreatedAt.year != createdAt.year)) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          bottom: 15.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            color: COMMON_BLACK,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.0,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  onSendMessage(String content) {
    ref.read(chatProvider(widget.id).notifier).sendMessage(
          content: content,
        );
  }
}

class BottomInput extends StatefulWidget {
  final Function(String) onSendMessage;
  const BottomInput({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<BottomInput> createState() => _BottomInputState();
}

class _BottomInputState extends State<BottomInput> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: BACKGROUND_LIGHT_BLACK,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: 15.0,
            ),
            // TODO : 이미지 전송 기능 추가
            // InkWell(
            //   onTap: () {},
            //   child: const Padding(
            //     padding: EdgeInsets.all(10.0),
            //     child: Icon(
            //       Icons.add_a_photo_outlined,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  controller: _textEditingController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  cursorColor: Colors.white,
                  cursorHeight: 16.0,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            if (_textEditingController.text.isNotEmpty)
              InkWell(
                onTap: () {
                  widget.onSendMessage(_textEditingController.text);
                  _textEditingController.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: PRIMARY_COLOR,
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      size: 24.0,
                      Icons.send,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
