import 'package:flutter/material.dart';
import 'package:client/common/const/colors.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final String backgroundImgPath;
  final Widget descriptionWidget;
  const CustomSliverAppBar({
    super.key,
    required this.title,
    required this.backgroundImgPath,
    required this.descriptionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: BACKGROUND_BLACK,
      // 맨 위에서 한계 이상으로 스크롤 했을때
      // 남는 공간을 차지
      stretch: true,
      // appBar의 길이
      expandedHeight: MediaQuery.of(context).size.width -
          MediaQuery.of(context).padding.top,
      // 상단 고정
      pinned: true,

      // 늘어났을때 어느것을 위치하고 싶은지
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'sabreshark',
                fontSize: 20.0,
              ),
            ),
            const SizedBox(width: 16.0),
          ],
        ),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.bottomLeft,
                  fit: BoxFit.cover,
                  image: AssetImage(
                    backgroundImgPath,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              child: descriptionWidget,
            ),
          ],
        ),
      ),
    );
  }
}
