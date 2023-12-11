import 'package:client/auth/view/join_screen.dart';
import 'package:client/auth/view/reset_password_screen.dart';
import 'package:client/common/components/custom_main_button.dart';
import 'package:client/common/components/custom_text_form_field.dart';
import 'package:client/common/components/default_moving_background.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/common/view/root_tab.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

typedef FutureBoolCallback = Future<bool> Function();

class LoginScreen extends ConsumerStatefulWidget {
  static String get routerName => "login";

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _email = "";

  String _password = "";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultMovingBackground(
        opacity: 0.2,
        filterColor: Colors.black,
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _emailLoginPart(
                    joinPressed: () {
                      context.pushNamed(JoinScreen.routeName);
                    },
                    passwordFindPressed: () {
                      context.pushNamed(ResetPasswordScreen.routeName);
                      //추후
                    },
                    loginPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            await emailLogin(
                              email: _email,
                              password: _password,
                            );
                            setState(() {
                              isLoading = false;
                            });
                          },
                  ),
                  const Divider(
                    color: INPUT_BG_COLOR,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  _socialLoginPart(),
                ],
              ),
            ),
          ),
        ]);
  }

  Widget _socialLoginPart() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        const Text(
          '소셜 로그인(추천)',
          style: TextStyle(
            color: INPUT_BG_COLOR,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 32.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _socialLoginBtn(
                url: "asset/imgs/logo/kakao_logo.png",
                onPresseExecute: kakaoLogin,
              ),
              _socialLoginBtn(
                url: "asset/imgs/logo/naver_logo.png",
                onPresseExecute: naverLogin,
              ),
              _socialLoginBtn(
                url: "asset/imgs/logo/google_logo.png",
                onPresseExecute: googleLogin,
              ),
              _socialLoginBtn(
                url: "asset/imgs/logo/apple_logo.png",
                onPresseExecute: appleLogin,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialLoginBtn({
    required String url,
    required FutureBoolCallback onPresseExecute,
  }) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        final resp = await onPresseExecute();
        if (resp) {
          context.goNamed(RootTab.routeName);
        } else {
          showSnackBar(
            content: "로그인에 실패했습니다",
          );
        }
        setState(() {
          isLoading = false;
        });
      },
      child: Image.asset(
        url,
        width: 47,
        height: 47,
      ),
    );
  }

  Widget _emailLoginPart({
    required VoidCallback joinPressed,
    required VoidCallback passwordFindPressed,
    required VoidCallback? loginPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          onChanged: (value) {
            _email = value;
          },
          labelText: "이메일",
        ),
        const SizedBox(height: 16.0),
        CustomTextFormField(
          obscureText: true,
          labelText: "패스워드",
          onChanged: (value) {
            _password = value;
          },
        ),
        const SizedBox(height: 32),
        CustomMainButton(
          onPressed: loginPressed,
          child: isLoading
              ? const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "로그인",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: joinPressed,
                child: const Text(
                  '이메일 회원가입',
                  style: TextStyle(
                    color: INPUT_BG_COLOR,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: passwordFindPressed,
                child: const Text(
                  '비밀번호 까묵',
                  style: TextStyle(
                    color: INPUT_BG_COLOR,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  showSnackBar({
    required String content,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  emailLogin({
    required String email,
    required String password,
  }) async {
    // validation
    if (email.isEmpty || password.isEmpty) {
      showSnackBar(
        content: "이메일과 비밀번호를 입력해주세요",
      );
      return;
    }

    final emailValid = DataUtils.isEmailValid(email);
    if (!emailValid) {
      showSnackBar(
        content: "이메일 형식이 올바르지 않습니다",
      );
      return;
    }

    if (password.length < 8) {
      showSnackBar(
        content: "비밀번호를 확인해주세요",
      );
      return;
    }

    final resp = await ref.read(userProvider.notifier).emailLogin(
          email: email,
          password: password,
        );
    // 추후 처리 필요
  }

  Future<bool> kakaoLogin() async {
    try {
      String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY']!;
      KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      // 이 다음에는 auth 진행

      await ref.read(userProvider.notifier).kakaoJoin(token.accessToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> googleLogin() async {
    return true;
  }

  Future<bool> appleLogin() async {
    return true;
  }

  Future<bool> naverLogin() async {
    return true;
    // try {
    //   final NaverLoginResult result = await FlutterNaverLogin.logIn();

    //   if (result.status == NaverLoginStatus.loggedIn) {
    //     print('accessToken = ${result.accessToken}');
    //     print('id = ${result.account.id}');
    //     print('email = ${result.account.email}');
    //     print('name = ${result.account.name}');
    //   }
    //   return true;
    // } catch (e) {
    //   print(e);
    //   return false;
    // }
  }
}
