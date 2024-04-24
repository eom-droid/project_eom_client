import 'dart:async';

import 'package:client/common/components/custom_img_input.dart';
import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/components/full_loading_screen.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileModify extends ConsumerWidget {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController profileImgController = TextEditingController();
  static String get routeName => 'profileModify';
  ProfileModify({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.read(userProvider) as UserModel;
    nicknameController.text = me.nickname;
    profileImgController.text = me.profileImg ?? "";
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
            onPressed: () async {
              await onPressdSave(
                context: context,
                ref: ref,
              );
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImgInput(
                imgPath: profileImgController.text,
                onChanged: (value) {
                  profileImgController.text = value;
                },
                imageError: (errorMes) {},
                deleteBtnActive: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "닉네임 (2~15자)",
            style: TextStyle(
              color: BODY_TEXT_COLOR,
            ),
          ),
          CustomTextField(
            controller: nicknameController,
            maxLength: 15,
          ),
        ],
      ),
    );
  }

  onPressdSave({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      if (nicknameController.text.trim().isEmpty ||
          nicknameController.text.length > 15 ||
          nicknameController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("닉네임을 3~15자 내로 설정해주세요"),
          ),
        );
        return;
      }
      FullLoadingScreen(context).startLoading();

      final Map<String, dynamic> profile = {};
      MultipartFile? profileImg;
      if (profileImgController.text.isNotEmpty &&
          !profileImgController.text.startsWith("http")) {
        final String fileName = profileImgController.text.split('/').last;
        profileImg = await MultipartFile.fromFile(
          profileImgController.text,
          filename: fileName,
        );

        profile["profileImg"] = fileName;
      }

      if (profileImgController.text.startsWith("http")) {
        profile["profileImg"] = profileImgController.text;
      }

      profile["nickname"] = nicknameController.text;
      await ref.read(userProvider.notifier).updateProfile(profile, profileImg);
      Timer(const Duration(milliseconds: 500), () {
        FullLoadingScreen(context).stopLoading();
        context.pop();
      });
    } catch (error) {
      FullLoadingScreen(context).stopLoading();
    }
  }
}
