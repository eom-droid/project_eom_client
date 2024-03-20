import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final double fontSize;
  final bool underline;
  final int? maxLength;
  final void Function(String)? onChanged;
  const CustomTextField({
    super.key,
    this.hintText,
    this.fontSize = 15.0,
    required this.controller,
    this.underline = true,
    this.onChanged,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        maxLength: maxLength,
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
        decoration: underline
            ? const InputDecoration(
                counterStyle: TextStyle(
                  color: Colors.white,
                ),
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
              )
            : const InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              )

        // decoration: const InputDecoration(
        //   isDense: true,
        //   enabledBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(
        //       color: GRAY_TEXT_COLOR,
        //       width: 1.0,
        //     ),
        //   ),
        //   focusColor: Colors.white,
        //   focusedBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(
        //       color: Colors.white,
        //       width: 2.0,
        //     ),
        //   ),
        // ),
        );
  }
}
