import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/diary/model/diary_model.dart';

class DiaryCard extends StatelessWidget {
  final String id;
  final DateTime createdAt;
  final String thumbnail;
  final List<String> hashtags;
  final String title;

  const DiaryCard({
    Key? key,
    required this.id,
    required this.createdAt,
    required this.thumbnail,
    required this.hashtags,
    required this.title,
  }) : super(key: key);

  factory DiaryCard.fromModel({
    required DiaryModel model,
  }) {
    return DiaryCard(
      id: model.id,
      createdAt: model.createdAt,
      thumbnail: model.thumbnail,
      hashtags: model.hashtags,
      title: model.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String postDate =
        '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일';
    return Stack(
      children: [
        Hero(
          tag: 'thumbnail$id',
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 2.0,
                sigmaY: 2.0,
              ),
              child: Image.network(
                thumbnail,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.width - 32.0,
                width: double.infinity,
                key: UniqueKey(),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width - 32.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width - 32.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BACKGROUND_BLACK.withOpacity(0.7),
                  Colors.transparent,
                  BACKGROUND_BLACK.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.width - 32.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Text(
                  postDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        // hashtag prefix for #
                        hashtags.map((String e) => '#$e').join(' '),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
