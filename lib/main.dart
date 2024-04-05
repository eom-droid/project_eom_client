import 'package:client/common/provider/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future main() async {
  // HttpOverrides.global =
  //     NoCheckCertificateHttpOverrides(); // 생성된 HttpOverrides 객체 등록
  await dotenv.load(fileName: ".env");
  runApp(
    const ProviderScope(child: _App()),
  );
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라우터 설정
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // showPerformanceOverlay: true,
    );
  }
}

// class NoCheckCertificateHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
