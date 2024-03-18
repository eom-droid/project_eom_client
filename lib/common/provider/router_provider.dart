import 'package:client/auth/view/login_screen.dart';
import 'package:client/chat/view/chat_detail_screen.dart';
import 'package:client/chat/view/chat_screen.dart';
import 'package:client/common/view/splash_screen.dart';
import 'package:client/settings/view/apple_account_revoke_screen.dart';
import 'package:client/settings/view/google_account_revoke_screen.dart';
import 'package:client/settings/view/privacy_policy_screen.dart';
import 'package:client/settings/view/profile_modify_screen.dart';
import 'package:client/settings/view/settings_screen.dart';
import 'package:client/settings/view/terms_of_use_screen.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
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

class FadePage<T> extends CupertinoPage<T> {
  const FadePage({
    required super.child,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class RouterProvider extends ChangeNotifier {
  final Ref ref;

  RouterProvider({required this.ref}) {
    ref.listen<UserModelBase?>(userProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          name: RootTab.routeName,
          // builder: (_, __) => const RootTab(),
          pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: const RootTab(),
          ),
          routes: [
            GoRoute(
              path: 'diary',
              name: DiaryScreen.routeName,
              // builder: (_, state) => DiaryScreen(),
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: DiaryScreen(),
              ),
            ),
            GoRoute(
              path: 'diary/:rid',
              name: DiaryDetailScreen.routeName,
              // builder: (_, state) => DiaryDetailScreen(
              //   id: state.pathParameters['rid']!,
              // ),
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: DiaryDetailScreen(
                  id: state.pathParameters['rid']!,
                ),
              ),
            ),
            GoRoute(
              path: 'music',
              name: MusicScreen.routeName,
              // builder: (_, state) => MusicScreen(),
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: MusicScreen(),
              ),
            ),
            GoRoute(
              path: 'chat',
              name: ChatScreen.routeName,
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const ChatScreen(),
              ),
            ),
            GoRoute(
              path: 'chat/:rid',
              name: ChatDetailScreen.routeName,
              // builder: (_, state) => ChatDetailScreen(
              //   id: state.pathParameters['rid']!,
              // ),
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: ChatDetailScreen(
                  id: state.pathParameters['rid']!,
                ),
              ),
            ),
            GoRoute(
              path: "login",
              name: LoginScreen.routerName,
              // builder: (context, state) => const LoginScreen(),
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const LoginScreen(),
              ),
            ),
            // GoRoute(
            //   path: "join",
            //   name: JoinScreen.routeName,
            //   // builder: (context, state) => const JoinScreen(),
            //   pageBuilder: (context, state) =>
            //       buildPageWithDefaultTransition<void>(
            //     context: context,
            //     state: state,
            //     child: const JoinScreen(),
            //   ),
            // ),
            // GoRoute(
            //   path: "resetPassword",
            //   name: ResetPasswordScreen.routeName,
            //   // builder: (context, state) => const ResetPasswordScreen(),
            //   pageBuilder: (context, state) =>
            //       buildPageWithDefaultTransition<void>(
            //     context: context,
            //     state: state,
            //     child: const ResetPasswordScreen(),
            //   ),
            // ),
            GoRoute(
                path: "settings",
                name: SettingsScreen.routeName,
                pageBuilder: (context, state) =>
                    buildPageWithDefaultTransition<void>(
                      context: context,
                      state: state,
                      child: const SettingsScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: "privacyPolicy",
                    name: PrivacyPolicyScreen.routeName,
                    pageBuilder: (context, state) =>
                        buildPageWithDefaultTransition<void>(
                      context: context,
                      state: state,
                      child: PrivacyPolicyScreen(),
                    ),
                  ),
                  GoRoute(
                    path: "termsOfUse",
                    name: TermsOfUseScreen.routeName,
                    pageBuilder: (context, state) =>
                        buildPageWithDefaultTransition<void>(
                      context: context,
                      state: state,
                      child: TermsOfUseScreen(),
                    ),
                  ),
                  GoRoute(
                    path: "profileModify",
                    name: ProfileModify.routeName,
                    pageBuilder: (context, state) =>
                        buildPageWithDefaultTransition<void>(
                      context: context,
                      state: state,
                      child: ProfileModify(),
                    ),
                  ),
                  GoRoute(
                    path: "appleAccountRevoke",
                    name: AppleAccountRevokeScreen.routeName,
                    pageBuilder: (context, state) =>
                        buildPageWithDefaultTransition<void>(
                      context: context,
                      state: state,
                      child: AppleAccountRevokeScreen(),
                    ),
                  ),
                  GoRoute(
                    path: "googleAccountRevoke",
                    name: GoogleAccountRevokeScreen.routeName,
                    pageBuilder: (context, state) =>
                        buildPageWithDefaultTransition<void>(
                      context: context,
                      state: state,
                      child: GoogleAccountRevokeScreen(),
                    ),
                  ),
                ])
          ],
        ),
        GoRoute(
          path: "/splash",
          name: SplashScreen.routeName,
          pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: const SplashScreen(),
          ),
        ),
      ];

  String? redirectLogic(BuildContext _, GoRouterState state) {
    final UserModelBase? user = ref.read(userProvider);

    final loginRoute = state.matchedLocation == '/login';
    final splashRoute = state.matchedLocation == '/splash';
    if (user is UserModelError) {
      print(user.message);
    }

    // 유저 정보가 없는데
    // 로그인 중이면 그대로 로그인 페이지에 두고
    // 만약 로그인중이 아니라면 로그인 페이지로 이동

    // UserModelError
    // 무조건 login페이지로 이동
    if (user == null || user is UserModelError) {
      return loginRoute ? null : '/login';
    }

    // user가 null이 아님

    // UserModel
    // 사용자 정보가 있는 상태면
    // 로그인 중이거나 현재 위치가 SplashScreen이면
    // 홈으로 이동
    if (user is UserModel) {
      return loginRoute || splashRoute ? '/' : null;
    }

    return null;
  }
}
