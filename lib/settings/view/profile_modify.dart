import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileModify extends ConsumerWidget {
  final String nickname;
  final TextEditingController controller = TextEditingController();
  static String get routeName => 'profileModify';
  ProfileModify({
    super.key,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    controller.text = nickname;
    return DefaultLayout(
      backgroundColor: BACKGROUND_BLACK,
      appBar: AppBar(
        title: const Text(
          "Profile Modify",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'sabreshark',
            fontSize: 20.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).updateNickname(controller.text);
              context.pop();
            },
            child: const Text(
              "완료",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: BACKGROUND_BLACK,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "닉네임",
            style: TextStyle(
              color: BODY_TEXT_COLOR,
            ),
          ),
          CustomTextField(
            controller: controller,
          ),
        ],
      ),
    );
  }
}
