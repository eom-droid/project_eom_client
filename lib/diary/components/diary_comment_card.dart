import 'package:client/common/const/colors.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/diary/model/diary_comment_model.dart';
import 'package:client/user/model/user_model.dart';
import 'package:flutter/material.dart';

class DiaryCommentCard extends StatelessWidget {
  final String id;
  final UserModel writer;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLike;
  final Function(String commentId) onLike;

  const DiaryCommentCard({
    super.key,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLike,
    required this.id,
    required this.writer,
    required this.onLike,
  });

  factory DiaryCommentCard.fromModel({
    required DiaryCommentModel model,
    required Function(String commentId) onLike,
  }) {
    return DiaryCommentCard(
      id: model.id,
      content: model.content,
      createdAt: model.createdAt,
      likeCount: model.likeCount,
      isLike: model.isLike,
      writer: model.writer,
      onLike: onLike,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                width: 18.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      writer.nickname,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DataUtils.timeAgoSinceDate(createdAt),
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: GRAY_TEXT_COLOR,
                          ),
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        if (likeCount > 0)
                          Text(
                            "좋아요 $likeCount개",
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: GRAY_TEXT_COLOR,
                            ),
                          ),
                        const SizedBox(
                          width: 6.0,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
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
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  onLike(id);
                },
                icon: Icon(
                  isLike ? Icons.favorite : Icons.favorite_border,
                  size: 20.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
