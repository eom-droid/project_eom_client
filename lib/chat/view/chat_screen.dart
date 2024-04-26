import 'package:client/chat/model/chat_message_model.dart';
import 'package:client/chat/model/chat_model.dart';
import 'package:client/chat/provider/chat_provider.dart';
import 'package:client/chat/view/chat_detail_screen.dart';
import 'package:client/common/components/cursor_pagination_error_comp.dart';
import 'package:client/common/components/cursor_pagination_loading_comp.dart';
import 'package:client/common/components/custom_circle_avatar.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chat';

  const ChatScreen({
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // ref.read(chatProvider.notifier).reconnect();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(chatProvider.notifier).reJoinRoom(
            roomId: "",
            route: ChatScreen.routeName,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final me = ref.read(userProvider);

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
        state: chatState,
        buildContext: context,
        me: me as UserModel,
      ),
    );
  }

  Widget loadBody({
    required CursorPaginationBase state,
    required BuildContext buildContext,
    required UserModel me,
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
          ref.read(chatProvider.notifier).reconnect();
        },
      );
    }

    final cp = state as CursorPagination<ChatModel>;

    if (cp.data.isEmpty) {
      return const Center(
        child: Text(
          '채팅방이 없습니다.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      );
    }
    return _body(
      chat: cp.data[0],
      parentBuildContext: buildContext,
      me: me,
    );
  }

  _body({
    required ChatModel chat,
    required BuildContext parentBuildContext,
    required UserModel me,
  }) {
    final otherUserProfileImg =
        chat.members.firstWhere((element) => element.id != me.id).profileImg;
    final phoneWidth = MediaQuery.of(parentBuildContext).size.width;
    return Center(
        child: GestureDetector(
      onTap: () async {
        parentBuildContext.pushNamed(
          ChatDetailScreen.routeName,
          pathParameters: {
            'rid': chat.id,
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
        width: phoneWidth / 1.5,
        child: Stack(
          alignment: Alignment.topCenter,
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
                    "주인장",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  // profileImage를 원으로 자르기
                  CustomCircleAvatar(
                    url: otherUserProfileImg,
                    size: phoneWidth / 2.8,
                    borderRadius: phoneWidth / 8,
                  ),
                  const SizedBox(height: 30.0),
                  _ChatPreviewWidget(
                    chat: chat,
                  ),
                ],
              ),
            ),
            _NewChatNotifier(
              myId: me.id,
              chat: chat,
            )
          ],
        ),
      ),
    ));
  }
}

class _NewChatNotifier extends StatelessWidget {
  final String myId;
  final ChatModel chat;

  const _NewChatNotifier({
    required this.myId,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    ChatMessageModel? lastMessage;
    final me = chat.members.firstWhereOrNull((element) => element.id == myId);

    if (chat is ChatDetailModel) {
      final pChat = chat as ChatDetailModel;
      if (pChat.messages.isEmpty) {
        lastMessage = null;
      } else {
        lastMessage = pChat.messages
            .where((element) =>
                element is! ChatMessageFailedModel ||
                element is! ChatMessageTempModel)
            .firstOrNull;
      }
    } else {
      lastMessage = chat.lastMessage;
    }

    if (me != null &&
        lastMessage != null &&
        lastMessage.id != me.lastReadChatId) {
      return Positioned(
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
            'New',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class _ChatPreviewWidget extends StatelessWidget {
  final ChatModel chat;
  const _ChatPreviewWidget({
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    ChatMessageModel? lastChat;
    if (chat is ChatDetailModel) {
      final pChat = chat as ChatDetailModel;
      if (pChat.messages.isEmpty) {
        lastChat = null;
      } else {
        lastChat = pChat.messages
            .where((element) =>
                element is! ChatMessageFailedModel ||
                element is! ChatMessageTempModel)
            .firstOrNull;
      }
    } else {
      lastChat = chat.lastMessage;
    }
    return Column(
      children: [
        Text(
          lastChat != null ? lastChat.content : '첫 메시지를 남겨봐요!',
          style: const TextStyle(
            color: INPUT_BG_COLOR,
            fontSize: 14.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6.0),
        Text(
          lastChat != null
              ? DataUtils.timeAgoSinceDate2(lastChat.createdAt)
              : '',
          style: const TextStyle(
            color: BODY_TEXT_COLOR,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
