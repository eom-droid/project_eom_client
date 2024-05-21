import 'dart:convert';

import 'package:client/common/components/custom_app_bar.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routerName => "login";

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLoading = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101010))
      ..setUserAgent("random")
      ..addJavaScriptChannel(
        "toApp",
        onMessageReceived: (JavaScriptMessage msg) {
          try {
            Map valueMap = jsonDecode(msg.message);
            final String accessToken = valueMap['accessToken'];
            final String refreshToken = valueMap['refreshToken'];
            ref.read(userProvider.notifier).loginWithTokens(
                  accessToken: accessToken,
                  refreshToken: refreshToken,
                );
            if (context.canPop()) {
              context.pop();
            }
          } catch (e) {
            // router pop
            context.pop();
          }
        },
      )
      ..loadRequest(Uri.parse(dotenv.env["WEB_URL"]!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: BACKGROUND_BLACK,
      isFullScreen: true,
      appBar: CustomAppBar(
        close: () async {
          // 만약 뒤로 더 갈 수 없다면
          if (await (_webViewController!.canGoBack()) == false) {
            context.pop();
          }
          _webViewController!.goBack();
        },
      ),
      child: WebViewWidget(
        controller: _webViewController!,
      ),
    );
  }
}
