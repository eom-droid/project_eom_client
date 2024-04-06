import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final double? borderRadius;
  const CustomCircleAvatar({
    super.key,
    required this.url,
    this.size = 40.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    print(url);
    return ClipRRect(
      borderRadius: borderRadius == null
          ? BorderRadius.circular(size / 2.5)
          : BorderRadius.circular(borderRadius!),
      child: Container(
        color: Colors.grey,
        width: size,
        height: size,
        child: url != null
            // ? Image.network(
            //     url!,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return questionMark(
            //         size,
            //       );
            //     },
            //   )
            // 나중에 손봐야될듯 캐시를 사용하니까 프로필을 변경할때 문제가 생김
            ? CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: url!,
                errorWidget: (context, url, error) => questionMark(
                  size,
                ),
                errorListener: (value) {
                  print('errorListener: $value');
                },
              )
            : questionMark(
                size,
              ),
      ),
    );
  }

  questionMark(double size) {
    return Icon(
      Icons.question_mark,
      size: size / 2.0,
    );
  }
}
