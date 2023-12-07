import 'package:client/common/layout/default_layout.dart';
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
    return DefaultLayout(
      child: SafeArea(
        top: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await kakaoLogin(ref: ref);
              },
              child: const Text('카카오 로그인'),
            )
          ],
        ),
      ),
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
