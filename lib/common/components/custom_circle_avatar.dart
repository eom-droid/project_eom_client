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
    return ClipRRect(
      borderRadius: borderRadius == null
          ? BorderRadius.circular(size / 2.5)
          : BorderRadius.circular(borderRadius!),
      child: Container(
        color: Colors.grey,
        width: size,
        height: size,
        child: url != null
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
