import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppleAccountRevokeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'apple_account_revoke';

  const AppleAccountRevokeScreen({super.key});

  @override
  ConsumerState<AppleAccountRevokeScreen> createState() =>
      _AppleAccountRevokeScreenState();
}

class _AppleAccountRevokeScreenState
    extends ConsumerState<AppleAccountRevokeScreen> {
  WebViewController? _webViewController;

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101010))
      ..addJavaScriptChannel("toApp",
          onMessageReceived: (JavaScriptMessage msg) {
        try {
          ref.read(userProvider.notifier).logoutWithoutRequest();
        } catch (e) {}
      })
      ..loadRequest(
          Uri.parse("${dotenv.env["WEB_URL"]!}/apple-account-revoke"));
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isFullScreen: true,
      appBar: AppBar(
        title: const Text(
          "Apple Account Revoke",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'sabreshark',
            fontSize: 20.0,
          ),
        ),
        elevation: 0,
        backgroundColor: BACKGROUND_BLACK,
      ),
      child: WebViewWidget(
        controller: _webViewController!,
      ),
    );
  }
}
