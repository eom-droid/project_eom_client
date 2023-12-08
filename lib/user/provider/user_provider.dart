import 'package:client/auth/respository/auth_repository.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/user/model/user_with_token_model.dart';
import 'package:client/user/respository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userProvider =
    StateNotifierProvider<UserStateNotifier, UserWithTokenModelBase?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return UserStateNotifier(
    authRepository: authRepository,
    userRepository: userRepository,
    secureStorage: secureStorage,
  );
});

class UserStateNotifier extends StateNotifier<UserWithTokenModelBase?> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final FlutterSecureStorage secureStorage;
  UserStateNotifier({
    required this.authRepository,
    required this.userRepository,
    required this.secureStorage,
  }) : super(UserWithTokenModelLoading()) {
    autoLogin();
  }

  Future<void> autoLogin() async {
    final refreshToken = await secureStorage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await secureStorage.read(key: ACCESS_TOKEN_KEY);

    if (refreshToken == null || accessToken == null) {
      state = null;
      return;
    }
    try {
      final token = await authRepository.getAccessTokenByRefreshToken(
        refreshToken: refreshToken,
      );

      if (token == null) {
        throw Exception("토큰이 없습니다.");
      }

      final user = await userRepository.getMe(
        accessTokenWithBearer: "Bearer ${token.accessToken}",
      );

      if (user == null) {
        throw Exception("유저 정보가 없습니다.");
      }

      state = UserWithTokenModel(token: token, user: user);
    } catch (e, stack) {
      print(e);
      print(stack);
      state = null;
    }
  }

  Future<String> getAccessTokenByRefreshToken({
    required String refreshToken,
  }) async {
    final token = await authRepository.getAccessTokenByRefreshToken(
      refreshToken: refreshToken,
    );
    if (token == null) {
      throw Exception("토큰이 없습니다.");
    }
    await Future.wait([
      secureStorage.write(key: ACCESS_TOKEN_KEY, value: token.accessToken),
      secureStorage.write(key: REFRESH_TOKEN_KEY, value: token.refreshToken)
    ]);
    return token.accessToken;
  }

  kakaoJoin(String kakaoToken) async {
    try {
      final token = await authRepository.kakaoJoin(kakaoToken);
      if (token == null) {
        throw Exception("토큰이 없습니다.");
      }
      final user = await userRepository.getMe(
        accessTokenWithBearer: "Bearer ${token.accessToken}",
      );
      if (user == null) {
        throw Exception("유저 정보가 없습니다.");
      }

      // secureStorage write
      await Future.wait([
        secureStorage.write(key: ACCESS_TOKEN_KEY, value: token.accessToken),
        secureStorage.write(key: REFRESH_TOKEN_KEY, value: token.refreshToken)
      ]);

      state = UserWithTokenModel(token: token, user: user);
    } catch (e) {
      state = UserWithTokenModelError(message: "로그인 실패");
      return;
    }
  }

  logout() async {
    // await secureStorage.deleteAll();
    state = null;
  }
}
