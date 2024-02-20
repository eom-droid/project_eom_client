import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/settings/view/profile_modify.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  static String get routeName => 'settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userProvider) as UserModel;
    return DefaultLayout(
      backgroundColor: BACKGROUND_BLACK,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'sabreshark',
            fontSize: 20.0,
          ),
        ),
        elevation: 0,
        backgroundColor: BACKGROUND_BLACK,
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          _profilePart(
            nickname: me.nickname,
            context: context,
          ),
        ],
      ),
    );
  }

  _profilePart({
    required String nickname,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nickname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          child: const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              "프로필 수정",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14.0,
              ),
            ),
          ),
          onTap: () {
            context.pushNamed(
              ProfileModify.routeName,
              pathParameters: {
                'nickname': nickname,
              },
            );
          },
        )
      ],
    );
  }
}
