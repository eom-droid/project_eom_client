import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomMainButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const CustomMainButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PRIMARY_COLOR,
          disabledBackgroundColor: PRIMARY_COLOR,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: child);
  }
}
