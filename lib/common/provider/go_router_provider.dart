import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:client/common/provider/router_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // watch - 값이 변경되면 다시 빌드
  // read - 값이 변경되어도 다시 빌드하지 않음
  final provider = ref.read(routerProvider);

  return GoRouter(
    routes: provider.routes,
    initialLocation: '/',
    refreshListenable: provider,
    redirect: provider.redirectLogic,
  );
});
