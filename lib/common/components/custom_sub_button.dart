import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomSubButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double padding;
  const CustomSubButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: INPUT_BG_COLOR,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        side: const BorderSide(
          color: PRIMARY_COLOR,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: child,
      ),
    );
  }
}
