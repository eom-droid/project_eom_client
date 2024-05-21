import 'package:client/common/components/custom_circle_avatar.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/settings/view/apple_account_revoke_screen.dart';
import 'package:client/settings/view/privacy_policy_screen.dart';
import 'package:client/settings/view/profile_modify_screen.dart';
import 'package:client/settings/view/terms_of_use_screen.dart';
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
    final me = ref.watch(userProvider);
    if (me != null) {}

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
      child: me == null
          ? const Center(
              child: CircularProgressIndicator(
                color: PRIMARY_COLOR,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    _profilePart(
                      me: me as UserModel,
                      context: context,
                    ),
                    const SizedBox(height: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "서비스 안내",
                          style: TextStyle(
                            color: GRAY_TEXT_COLOR,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              TermsOfUseScreen.routeName,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Text(
                              "이용 약관",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              PrivacyPolicyScreen.routeName,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Text(
                              "개인정보 처리 방침",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 150),
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Text(
                          "로그아웃",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        ref.read(userProvider.notifier).logout();
                      },
                    ),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: BACKGROUND_BLACK,
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '정말로 탈퇴하시겠습니까?',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      if (me.provider == apple)
                                        const Text(
                                          "* 애플 계정으로 가입하신경우에는 탈퇴를 위한 인증 1회가 필요합니다.",
                                          style: TextStyle(
                                            color: GRAY_TEXT_COLOR,
                                          ),
                                        ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        if (me.provider == apple) {
                                          context.pushNamed(
                                            AppleAccountRevokeScreen.routeName,
                                          );
                                        } else {
                                          ref
                                              .read(userProvider.notifier)
                                              .revokeAccount();
                                        }
                                      },
                                      child: const Text(
                                        '탈퇴',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        '취소',
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            "엄태호(Eom Tae Ho) 탈퇴",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: BODY_TEXT_COLOR,
                              fontSize: 14.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  _profilePart({
    required UserModel me,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CustomCircleAvatar(
              url: me.profileImg,
              size: 100,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          me.nickname,
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
                fontSize: 18.0,
              ),
            ),
          ),
          onTap: () {
            context.pushNamed(
              ProfileModify.routeName,
            );
          },
        ),
      ],
    );
  }
}
