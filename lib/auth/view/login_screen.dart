import 'package:client/common/components/custom_main_button.dart';
import 'package:client/common/components/custom_text_form_field.dart';
import 'package:client/common/components/default_moving_background.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends ConsumerWidget {
  static String get routerName => "login";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    return DefaultMovingBackground(
      child: SafeArea(
        bottom: true,
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _appBar(width: width),
            ),
            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            const SizedBox(height: 24.0),
            _emailLoginPart(),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Divider(
                color: Colors.white,
                thickness: 1,
              ),
            ),
            _socialLoginPart(),
          ],
        ),
      ),
    );
  }

  Widget _socialLoginPart() {
    return const Column(
      children: [
        Text('소셜 로그인', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _emailLoginPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '이메일',
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            onChanged: (value) {},
          ),
          const SizedBox(height: 16.0),
          const Text(
            '패스워드',
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            obscureText: true,
            onChanged: (value) {},
          ),
          const SizedBox(height: 32),
          CustomMainButton(text: "로그인", onPressed: () {}),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '이메일 회원가입',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '비밀번호 까묵',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appBar({
    required double width,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: width * 0.1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                "asset/imgs/logo/logo.png",
                width: width * 0.1,
                height: width * 0.1,
              ),
              const SizedBox(width: 16),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Eom Tae Ho',
                  style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: "sabreshark",
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Icon(
            Icons.close_sharp,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  kakaoLogin({
    required WidgetRef ref,
  }) async {
    String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY']!;
    KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

    bool isInstalled = await isKakaoTalkInstalled();

    OAuthToken token = isInstalled
        ? await UserApi.instance.loginWithKakaoTalk()
        : await UserApi.instance.loginWithKakaoAccount();
    // 이 다음에는 auth 진행

    ref.read(userProvider.notifier).kakaoJoin(token.accessToken);
  }
}
