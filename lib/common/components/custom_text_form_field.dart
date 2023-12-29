import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final String? labelText;
  final bool obscureText;
  final bool autofocus;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool? enable;
  final int? maxLine;
  final TextEditingController? controller;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.enable = true,
    this.controller,
    this.maxLine,
  });

  @override
  Widget build(BuildContext context) {
    const baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: INPUT_BORDER_COLOR,
        width: 1.0,
      ),
    );

    if (labelText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            labelText!,
            style: const TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          textFormFiled(baseBorder),
        ],
      );
    }
    return textFormFiled(baseBorder);
  }

  Widget textFormFiled(OutlineInputBorder baseBorder) {
    return TextFormField(
      maxLines: maxLine ?? 1,
      keyboardType: keyboardType,
      cursorColor: PRIMARY_COLOR,
      // 비밀번호 입력할때
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      enabled: enable,
      controller: controller,

      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: BODY_TEXT_COLOR,
          fontSize: 14.0,
        ),
        errorText: errorText,
        fillColor: enable! ? INPUT_BG_COLOR : BODY_TEXT_COLOR,
        errorStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 213, 210),
          fontSize: 12.0,
        ),
        // false - 배경색 없음
        // true - 배경색 있음
        filled: true,
        // 모든 input 상태의 기본 스타일 세팅
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: PRIMARY_COLOR,
          ),
        ),
      ),
    );
  }
}
