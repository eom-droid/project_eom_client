import 'package:client/common/components/custom_circle_avatar.dart';
import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/diary/model/diary_comment_model.dart';
import 'package:client/diary/model/diary_reply_model.dart';
import 'package:client/diary/provider/diary_reply_provider.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryCommentCard extends ConsumerStatefulWidget {
  final String commentId;
  final String diaryId;
  final UserModel? writer;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLike;
  final VoidCallback onLike;
  final bool isCommentMine;
  final int replyCount;
  final VoidCallback onDelete;
  final Function(String) onUpdate;

  const DiaryCommentCard({
    super.key,
    required this.diaryId,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLike,
    required this.commentId,
    this.writer,
    required this.onLike,
    required this.isCommentMine,
    required this.onDelete,
    required this.replyCount,
    required this.onUpdate,
  });

  factory DiaryCommentCard.fromModel({
    required DiaryCommentModel model,
    required String diaryId,
    required VoidCallback onLike,
    required VoidCallback onDelete,
    required Function(String) onUpdate,
    required bool isCommentMine,
  }) {
    return DiaryCommentCard(
      diaryId: diaryId,
      commentId: model.id,
      content: model.content,
      createdAt: model.createdAt,
      likeCount: model.likeCount,
      isLike: model.isLike,
      writer: model.writer,
      onLike: onLike,
      isCommentMine: isCommentMine,
      onDelete: onDelete,
      onUpdate: onUpdate,
      replyCount: model.replyCount,
    );
  }

  @override
  ConsumerState<DiaryCommentCard> createState() => _DiaryCommentCardState();
}

class _DiaryCommentCardState extends ConsumerState<DiaryCommentCard> {
  // 답글을 보여줄지 말지
  bool showReply = false;
  // 답글을 작성하는 input을 보여줄지 말지
  bool showReplyInput = false;
  // 답글을 작성하는 input의 컨트롤러
  final TextEditingController replyController = TextEditingController();

  // 수정을 위한 변수
  bool isCommentUpdating = false;
  String replyUpdatingId = "";

  // 수정을 위한 컨트롤러
  final TextEditingController commentUpdateController = TextEditingController();
  final TextEditingController replyUpdateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final replyState = ref.watch(diaryReplyProvider(widget.commentId));

    final userState = ref.watch(userProvider) as UserModel;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: widget.isCommentMine
                ? () {
                    showDeleteDialog(
                      context: context,
                      onUpdate: () {
                        setState(() {
                          isCommentUpdating = true;
                          commentUpdateController.text = widget.content;
                        });
                      },
                      onDelete: widget.onDelete,
                    );
                  }
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2.0,
                  ),
                  child: CustomCircleAvatar(
                    url: widget.writer?.profileImg,
                  ),
                ),
                const SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      DataUtils.timeAgoSinceDate(
                                          widget.createdAt),
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
                                if (isCommentUpdating)
                                  Column(
                                    children: [
                                      CustomTextField(
                                        controller: commentUpdateController,
                                        fontSize: 14.0,
                                      ),
                                      const SizedBox(
                                        height: 12.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isCommentUpdating = false;
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
                                            onTap: () {
                                              widget.onUpdate(
                                                  commentUpdateController.text);
                                              setState(() {
                                                isCommentUpdating = false;
                                              });
                                            },
                                            child: const Text(
                                              "수정",
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
                                if (!isCommentUpdating)
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
                              ],
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onLike,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                12.0,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    widget.isLike
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20.0,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    widget.likeCount > 0
                                        ? DataUtils.number2Unit
                                            .format(widget.likeCount)
                                        : "",
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showReplyInput)
            replyInput(
              userState: userState,
              controller: replyController,
              onReply: () {
                ref
                    .read(diaryReplyProvider(widget.commentId).notifier)
                    .createReply(
                      content: replyController.text,
                      commentId: widget.commentId,
                      diaryId: widget.diaryId,
                    );
                replyController.text = "";
                setState(() {
                  showReplyInput = false;
                  showReply = true;
                });
              },
            ),
          if (showReply && replyState is CursorPagination)
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 56.0,
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final reply =
                      (replyState as CursorPagination<DiaryReplyModel>)
                          .data[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: reply.writer != null &&
                            reply.writer!.id == userState.id
                        ? () {
                            showDeleteDialog(
                              context: context,
                              onUpdate: () {
                                setState(() {
                                  replyUpdatingId = reply.id;
                                  replyUpdateController.text = reply.content;
                                });
                              },
                              onDelete: () {
                                ref
                                    .read(diaryReplyProvider(widget.commentId)
                                        .notifier)
                                    .deleteReply(
                                      replyId: reply.id,
                                      commentId: widget.commentId,
                                      diaryId: widget.diaryId,
                                    );
                              },
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.5,
                            ),
                            child: CustomCircleAvatar(
                              url: reply.writer?.profileImg,
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
                                Row(
                                  children: [
                                    Text(
                                      reply.writer != null
                                          ? reply.writer!.nickname
                                          : "삭제된 사용자",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: reply.writer != null
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 6.0,
                                    ),
                                    Text(
                                      DataUtils.timeAgoSinceDate(
                                        reply.createdAt,
                                      ),
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
                                if (replyUpdatingId == reply.id)
                                  Column(
                                    children: [
                                      CustomTextField(
                                        controller: replyUpdateController,
                                        fontSize: 14.0,
                                      ),
                                      const SizedBox(
                                        height: 12.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                replyUpdatingId = "";
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
                                            onTap: () {
                                              ref
                                                  .read(diaryReplyProvider(
                                                          widget.commentId)
                                                      .notifier)
                                                  .patchReply(
                                                    content:
                                                        replyUpdateController
                                                            .text,
                                                    replyId: reply.id,
                                                  );
                                              setState(() {
                                                replyUpdatingId = "";
                                              });
                                            },
                                            child: const Text(
                                              "수정",
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
                                if (replyUpdatingId != reply.id)
                                  Text(
                                    reply.content,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              ref
                                  .read(diaryReplyProvider(widget.commentId)
                                      .notifier)
                                  .toggleLike(
                                    replyId: reply.id,
                                  );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    reply.isLike
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20.0,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    reply.likeCount > 0
                                        ? DataUtils.number2Unit
                                            .format(reply.likeCount)
                                        : "",
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
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 10.0,
                  );
                },
                itemCount: (replyState).data.length,
              ),
            ),
          if (replyState is CursorPagination && widget.replyCount > 0)
            replyShowButton(
              replyState: replyState as CursorPagination<DiaryReplyModel>,
            ),
        ],
      ),
    );
  }

  Widget replyShowButton({
    required CursorPagination<DiaryReplyModel> replyState,
  }) {
    int currentState = (replyState.meta.hasMore &&
                widget.replyCount != replyState.data.length) ||
            !showReply
        ? showReply || replyState.data.isEmpty
            ? 1
            : 2
        : 0;

    return Padding(
      padding: const EdgeInsets.only(
        left: 56.0,
      ),
      child: GestureDetector(
        onTap: () {
          if (currentState == 0) {
            setState(() {
              showReply = !showReply;
            });
          }
          if (currentState == 1) {
            if (!showReply) {
              setState(() {
                showReply = !showReply;
              });
            }
            ref.read(diaryReplyProvider(widget.commentId).notifier).paginate(
                  bounceMilSec: 100,
                  fetchMore: replyState.meta.count == 0
                      ? false
                      : replyState.meta.hasMore,
                );
          }
          if (currentState == 2) {
            setState(() {
              showReply = !showReply;
            });
          }
          return;
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
                currentState == 0
                    ? "답글 숨기기"
                    : currentState == 1
                        ? "답글 ${DataUtils.number2Unit.format((widget.replyCount - replyState.data.length).abs())}개 보기"
                        : "답글 ${DataUtils.number2Unit.format(replyState.data.length)}개 보기",
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
    );
  }

  Widget replyInput({
    required TextEditingController controller,
    required VoidCallback onReply,
    required UserModel userState,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 56.0,
        right: 48.0,
        top: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: CustomCircleAvatar(
              url: userState.profileImg,
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
                        replyController.text = "";
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

  showDeleteDialog({
    required BuildContext context,
    required Function() onUpdate,
    required Function() onDelete,
  }) {
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
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete();
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
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pop();
                  onUpdate();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 13.0,
                  ),
                  child: Text(
                    '수정',
                    style: TextStyle(
                      color: Colors.blue,
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
                behavior: HitTestBehavior.opaque,
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
