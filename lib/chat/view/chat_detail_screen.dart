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

  Widget loadBody(CursorPaginationBase state, ChatRoomModel? room) {
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

    // CursorPagination
    // CursorPaginationFetchMore
    // CursorPaginationRefetching

    return _body();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.id));
    final room = ref.read(chatRoomProvider.notifier).getChatRoomInfo(widget.id);

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
        chatState,
        room,
      ),
    );
  }

  Widget _body() {
    return SafeArea(
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
            child: BottomInput(
              onSendMessage: onSendMessage,
            ),
          ),
        ],
      ),
    );
  }

  onSendMessage(String content) {
    print(content);
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
