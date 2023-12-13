import 'package:client/auth/view/join_screen.dart';
import 'package:client/auth/view/login_screen.dart';
import 'package:client/auth/view/reset_password_screen.dart';
import 'package:client/common/view/splash_screen.dart';
import 'package:client/user/model/user_with_token_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:client/common/view/root_tab.dart';
import 'package:client/diary/view/diary_detail_screen.dart';
import 'package:client/diary/view/diary_screen.dart';
import 'package:client/music/view/music_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // watch - 값이 변경되면 다시 빌드
  // read - 값이 변경되어도 다시 빌드하지 않음
  final provider = ref.read(routerProvider);

  return GoRouter(
    routes: provider.routes,
    initialLocation: '/splash',
    refreshListenable: provider,
    redirect: provider.redirectLogic,
  );
});

final routerProvider = ChangeNotifierProvider<RouterProvider>((ref) {
  return RouterProvider(ref: ref);
});

class RouterProvider extends ChangeNotifier {
  final Ref ref;

  RouterProvider({required this.ref}) {
    ref.listen<UserWithTokenModelBase?>(userProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          name: RootTab.routeName,
          builder: (_, __) => const RootTab(),
          routes: [
            GoRoute(
              path: 'diary',
              name: DiaryScreen.routeName,
              builder: (_, state) => DiaryScreen(),
            ),
            GoRoute(
              path: 'diary/:rid',
              name: DiaryDetailScreen.routeName,
              builder: (_, state) => DiaryDetailScreen(
                id: state.pathParameters['rid']!,
              ),
            ),
            GoRoute(
              path: 'music',
              name: MusicScreen.routeName,
              builder: (_, state) => MusicScreen(),
            ),
            GoRoute(
              path: "login",
              name: LoginScreen.routerName,
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: "join",
              name: JoinScreen.routeName,
              builder: (context, state) => const JoinScreen(),
            ),
            GoRoute(
              path: "resetPassword",
              name: ResetPasswordScreen.routeName,
              builder: (context, state) => const ResetPasswordScreen(),
            ),
          ],
        ),
        GoRoute(
          path: "/splash",
          name: SplashScreen.routeName,
          builder: (context, state) => const SplashScreen(),
        ),
      ];

  String? redirectLogic(BuildContext _, GoRouterState state) {
    final UserWithTokenModelBase? user = ref.read(userProvider);
    final loginRoute = state.location == '/login';
    final joinRoute = state.location == '/join';
    final resetPasswordRoute = state.location == '/resetPassword';
    final splashRoute = state.location == '/splash';
    if (user is UserWithTokenModelError) {
      print(user.message);
    }

    // 유저 정보가 없는데
    // 로그인 중이면 그대로 로그인 페이지에 두고
    // 만약 로그인중이 아니라면 로그인 페이지로 이동

    // UserModelError
    // 무조건 login페이지로 이동
    if (user == null || user is UserWithTokenModelError) {
      return loginRoute || joinRoute || resetPasswordRoute ? null : '/login';
    }

    // user가 null이 아님

    // UserModel
    // 사용자 정보가 있는 상태면
    // 로그인 중이거나 현재 위치가 SplashScreen이면
    // 홈으로 이동
    if (user is UserWithTokenModel) {
      return loginRoute || joinRoute || resetPasswordRoute || splashRoute
          ? '/'
          : null;
    }

    return null;
  }
}
