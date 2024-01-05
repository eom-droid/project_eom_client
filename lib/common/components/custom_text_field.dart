import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final double fontSize;
  const CustomTextField({
    super.key,
    this.hintText,
    this.fontSize = 15.0,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.white,
      controller: controller,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
      decoration: const InputDecoration(
        isDense: true,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: GRAY_TEXT_COLOR,
            width: 1.0,
          ),
        ),
        focusColor: Colors.white,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
