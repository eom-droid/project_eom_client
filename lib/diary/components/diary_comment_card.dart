import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/diary/model/diary_comment_model.dart';
import 'package:client/diary/provider/diary_reply_provider.dart';
import 'package:client/user/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryCommentCard extends ConsumerStatefulWidget {
  final String id;
  final UserModel? writer;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLike;
  final VoidCallback onLike;
  final bool isCommentMine;
  final int replyCount;
  final VoidCallback onDelete;

  const DiaryCommentCard({
    super.key,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLike,
    required this.id,
    this.writer,
    required this.onLike,
    required this.isCommentMine,
    required this.onDelete,
    required this.replyCount,
  });

  factory DiaryCommentCard.fromModel({
    required DiaryCommentModel model,
    required VoidCallback onLike,
    required VoidCallback onDelete,
    required bool isCommentMine,
  }) {
    return DiaryCommentCard(
      id: model.id,
      content: model.content,
      createdAt: model.createdAt,
      likeCount: model.likeCount,
      isLike: model.isLike,
      writer: model.writer,
      onLike: onLike,
      isCommentMine: isCommentMine,
      onDelete: onDelete,
      replyCount: model.replyCount,
    );
  }

  @override
  ConsumerState<DiaryCommentCard> createState() => _DiaryCommentCardState();
}

class _DiaryCommentCardState extends ConsumerState<DiaryCommentCard> {
  bool showReply = false;
  bool showReplyInput = false;
  final TextEditingController replyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: widget.isCommentMine
            ? () {
                showDeleteDialog(context);
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 22.0,
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
            const SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.writer != null
                            ? widget.writer!.nickname
                            : "삭제된 사용자",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: widget.writer != null
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        width: 6.0,
                      ),
                      Text(
                        DataUtils.timeAgoSinceDate(widget.createdAt),
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: GRAY_TEXT_COLOR,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showReplyInput = !showReplyInput;
                      });
                    },
                    child: const Text(
                      "답글달기",
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: GRAY_TEXT_COLOR,
                      ),
                    ),
                  ),
                  if (showReplyInput)
                    replyInput(
                      controller: replyController,
                      onReply: () {
                        ref
                            .read(diaryReplyProvider(widget.id).notifier)
                            .createReply(
                              content: replyController.text,
                              commentId: widget.id,
                            );
                        setState(() {
                          showReplyInput = false;
                        });
                      },
                    ),
                  if (widget.replyCount > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showReply = !showReply;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 0.5,
                              decoration: const BoxDecoration(
                                color: GRAY_TEXT_COLOR,
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "답글 ${DataUtils.number2Unit.format(widget.replyCount)}개 보기",
                              style: const TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                color: GRAY_TEXT_COLOR,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onLike,
              child: Padding(
                padding: const EdgeInsets.all(
                  12.0,
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.isLike ? Icons.favorite : Icons.favorite_border,
                      size: 20.0,
                      color: Colors.white,
                    ),
                    if (widget.likeCount > 0)
                      Text(
                        DataUtils.number2Unit.format(widget.likeCount),
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: GRAY_TEXT_COLOR,
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

  Widget replyInput({
    required TextEditingController controller,
    required VoidCallback onReply,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 8.0,
            ),
            child: CircleAvatar(
              radius: 18.0,
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
          ),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 2.0,
                ),
                CustomTextField(
                  controller: controller,
                  fontSize: 14.0,
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showReplyInput = false;
                        });
                      },
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: GRAY_TEXT_COLOR,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onReply,
                      child: const Text(
                        "답글달기",
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(
              color: BODY_TEXT_COLOR,
              width: 1,
            ),
          ),
          backgroundColor: BACKGROUND_BLACK,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  widget.onDelete();
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 13.0,
                  ),
                  child: Text(
                    '삭제',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Divider(
                height: 0,
                color: BODY_TEXT_COLOR,
                thickness: 1,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 13.0,
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // fontFamily: "NotoSansCJKkr",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
