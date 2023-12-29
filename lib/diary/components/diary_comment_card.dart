import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class DiaryCommentCard extends StatelessWidget {
  final String nickname;
  final String? profileImg;

  const DiaryCommentCard({
    super.key,
    required this.nickname,
    this.profileImg,
  });

  // factory DiaryCommentCard.fromModel({
  //   required DiaryCommentModel model,
  // }) {
  //   return DiaryCommentCard(
  //     nickname: model.nickname,
  //     profileImg: model.profileImg,
  //   );
  // }

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
                      nickname,
                      style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    const Text(
                      '댓글 내용내용',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "2년전",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: GRAY_TEXT_COLOR,
                          ),
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        const Text(
                          "좋아요 3개",
                          style: TextStyle(
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
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite,
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
