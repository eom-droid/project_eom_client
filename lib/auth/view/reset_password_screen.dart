import 'package:client/auth/respository/auth_repository.dart';
import 'package:client/common/components/custom_main_button.dart';
import 'package:client/common/components/custom_sub_button.dart';
import 'package:client/common/components/custom_text_form_field.dart';
import 'package:client/common/components/default_moving_background.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  static String get routeName => "resetPassword";
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  String _email = "";

  String? _emailError;

  String _certificationNumber = "";

  String? _certificationNumberError;

  String _password = "";

  String? _passwordError;

  String _passwordCheck = "";

  String? _passwordCheckError;

  bool? _isVerifiactionCodeSent = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultMovingBackground(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        enable: _isVerifiactionCodeSent == null
                            ? false
                            : !_isVerifiactionCodeSent!,
                        labelText: '이메일',
                        hintText: "이메일",
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          _email = value;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    CustomSubButton(
                      onPressed: () {
                        if (_isVerifiactionCodeSent == null) {
                          return;
                        }
                        setState(() {
                          _isVerifiactionCodeSent = true;
                        });
                        sendVerificationCode(
                          email: _email,
                        );
                        setState(() {
                          _isVerifiactionCodeSent = true;
                        });
                      },
                      child: _isVerifiactionCodeSent == null
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: PRIMARY_COLOR,
                              ),
                            )
                          : Text(
                              _isVerifiactionCodeSent! ? "재발송" : "인증번호 발송",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: PRIMARY_COLOR,
                                fontSize: 16.0,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  labelText: '인증번호',
                  hintText: "인증번호",
                  errorText: _certificationNumberError,
                  onChanged: (value) {
                    _certificationNumber = value;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  labelText: '신규비밀번호',
                  hintText: "신규비밀번호",
                  errorText: _passwordError,
                  obscureText: true,
                  onChanged: (value) {
                    _password = value;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  labelText: '신규비밀번호 확인',
                  hintText: "신규비밀번호 확인",
                  errorText: _passwordCheckError,
                  obscureText: true,
                  onChanged: (value) {
                    _passwordCheck = value;
                  },
                ),
                const SizedBox(
                  height: 48.0,
                ),
                CustomMainButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          await join();
                          setState(() {
                            isLoading = false;
                          });
                        },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "회원가입",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  join() async {
    _emailError = null;
    _certificationNumberError = null;
    _passwordError = null;
    _passwordCheckError = null;

    if (_email.isEmpty) {
      showSnackBar(content: "이메일을 입력해주세요.");
      return;
    }

    final bool emailValid = DataUtils.isEmailValid(_email);

    if (!emailValid) {
      showSnackBar(content: "이메일 형식이 올바르지 않습니다.");
      _emailError = "이메일 형식이 올바르지 않습니다.";
      return;
    }

    if (_isVerifiactionCodeSent == null || !_isVerifiactionCodeSent!) {
      showSnackBar(content: "인증번호를 발송해주세요.");
      _emailError = "인증번호를 발송해주세요.";
      return;
    }

    if (_certificationNumber.isEmpty) {
      showSnackBar(content: "인증번호를 입력해주세요.");
      _certificationNumberError = "인증번호를 입력해주세요.";
      return;
    }

    if (_password.isEmpty) {
      showSnackBar(content: "비밀번호를 입력해주세요.");
      _passwordError = "비밀번호를 입력해주세요.";
      return;
    }
    if (_passwordCheck.length < 8) {
      showSnackBar(content: "비밀번호는 8자리 이상이어야 합니다.");
      _passwordError = "비밀번호는 8자리 이상이어야 합니다.";
      return;
    }

    if (_passwordCheck.isEmpty) {
      showSnackBar(content: "비밀번호 확인을 입력해주세요.");
      _passwordCheckError = "비밀번호 확인을 입력해주세요.";
      return;
    }

    if (_password != _passwordCheck) {
      showSnackBar(content: "비밀번호가 일치하지 않습니다.");
      _passwordCheckError = "비밀번호가 일치하지 않습니다.";
      return;
    }

    final joinResp = await ref.read(authRepositoryProvider).join(
          email: _email,
          password: _password,
          verificationCode: _certificationNumber,
        );

    if (!joinResp) {
      showSnackBar(content: "인증번호를 확인해주세요.");
      return;
    }
    showSnackBar(content: "회원가입이 완료되었습니다.");

    await ref.read(userProvider.notifier).emailLogin(
          email: _email,
          password: _password,
        );
    // 마지막에 라우팅이 없는 이유
    // userProvider에서 state가 변경됨에 따라 redirect 로직을 따르고 있기 때문
  }

  sendVerificationCode({
    required String email,
  }) async {
    if (email.isEmpty) {
      showSnackBar(content: "이메일을 입력해주세요.");
      return;
    }

    final bool emailValid = DataUtils.isEmailValid(email);

    if (!emailValid) {
      showSnackBar(content: "이메일 형식이 올바르지 않습니다.");
      return;
    }

    final result = await ref
        .read(authRepositoryProvider)
        .sendVerificationCode(email: email);

    if (result) {
      showSnackBar(content: "인증번호가 발송되었습니다.");
    } else {
      showSnackBar(content: "이미 가입된 이메일입니다.");
    }
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
}
