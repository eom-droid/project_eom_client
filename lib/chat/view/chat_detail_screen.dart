import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/model/chat_room_model.dart';
import 'package:client/chat/provider/chat_provider.dart';
import 'package:client/chat/provider/chat_room_provider.dart';
import 'package:client/common/components/cursor_pagination_error_comp.dart';
import 'package:client/common/components/cursor_pagination_loading_comp.dart';
import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/const/setting.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/user/model/user_with_token_model.dart';
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

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(listener);
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
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();

    super.dispose();
  }

  Widget loadBody({
    required CursorPaginationBase state,
    required ChatRoomModel? room,
    required UserWithTokenModelBase? user,
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

    if (user == null || user is! UserWithTokenModel) {
      return const Center(
        child: Text('유저 정보가 없습니다.'),
      );
    }

    // CursorPagination
    // CursorPaginationFetchMore
    // CursorPaginationRefetching

    final cp = state as CursorPagination<ChatModel>;
    return _body(
      cp: cp,
      room: room,
      me: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.id));
    final room = ref.read(chatRoomProvider.notifier).getChatRoomInfo(widget.id);
    final user = ref.watch(userProvider);

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
        user: user,
        state: chatState,
      ),
    );
  }

  Widget _body({
    required CursorPagination<ChatModel> cp,
    required ChatRoomModel room,
    required UserWithTokenModel me,
  }) {
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
                  final afterCreatedAt = index + 1 < cp.data.length
                      ? cp.data[index + 1].createdAt
                      : null;
                  final isMe = userId == me.user.id;
                  final user = isMe
                      ? me.user
                      : room.members.firstWhere(
                          (element) => element.id == userId,
                        );

                  final chat = cp.data[index];

                  bool showAvatar = afterCreatedAt == null
                      ? !isMe
                      : !isMe &&
                          (nextUserId != userId ||
                              afterCreatedAt.day != chat.createdAt.day ||
                              afterCreatedAt.month != chat.createdAt.month ||
                              afterCreatedAt.year != chat.createdAt.year ||
                              afterCreatedAt.hour != chat.createdAt.hour ||
                              afterCreatedAt.minute != chat.createdAt.minute);

                  return Column(
                    children: [
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
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 5.0,
                              ),
                              child: _chatTime(
                                chat.createdAt,
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 7.0,
                                ),
                                decoration: BoxDecoration(
                                  color: PRIMARY_COLOR,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  chat.content,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
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
                              const CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.grey,
                                // backgroundImage: AssetImage(
                                //   'assets/images/default_profile.png',
                                // ),
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: showAvatar ? 10 : 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showAvatar)
                                  Text(
                                    user.nickname,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(
                                  height: 5,
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
                                            vertical: 7.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BACKGROUND_LIGHT_BLACK,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Text(
                                            chat.content,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 5.0,
                                        ),
                                        child: _chatTime(
                                          chat.createdAt,
                                        ),
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
            horizontal: 10.0,
            vertical: 5.0,
          ),
          decoration: BoxDecoration(
            color: COMMON_BLACK,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      );
    } else {
      return Container();
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
                widget.onSendMessage(_textEditingController.text);
                _textEditingController.clear();
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
    );
  }
}
