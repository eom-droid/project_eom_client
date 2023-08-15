import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:client/common/view/root_tab.dart';
import 'package:client/diary/view/diary_detail_screen.dart';
import 'package:client/diary/view/diary_screen.dart';
import 'package:client/music/view/music_screen.dart';

final routerProvider = ChangeNotifierProvider<RouterProvider>((ref) {
  return RouterProvider(ref: ref);
});

class RouterProvider extends ChangeNotifier {
  final Ref ref;

  RouterProvider({required this.ref}) {
    // ref.listen<UserModelBase?>(userMeProiver, (previous, next) {
    //   if (previous != next) {
    //     notifyListeners();
    //   }
    // });
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
          ],
        ),
      ];

  String? redirectLogic(BuildContext _, GoRouterState state) {
    return null;
  }
}
