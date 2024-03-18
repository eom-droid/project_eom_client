import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleAccountRevokeScreen extends StatelessWidget {
  static String get routeName => 'google_account_revoke';

  final WebViewController _webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0xFF101010))
    ..loadRequest(Uri.parse("${dotenv.env["WEB_URL"]!}/google-account-revoke"));

  GoogleAccountRevokeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isFullScreen: true,
      appBar: AppBar(
        title: const Text(
          "Google Account Revoke",
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
        controller: _webViewController,
      ),
    );
  }
}
