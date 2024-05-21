import 'package:client/auth/respository/auth_repository.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/respository/user_repository.dart';
import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userProvider =
    StateNotifierProvider<UserStateNotifier, UserModelBase?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return UserStateNotifier(
    authRepository: authRepository,
    userRepository: userRepository,
    secureStorage: secureStorage,
  );
});

class UserStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final FlutterSecureStorage secureStorage;
  UserStateNotifier({
    required this.authRepository,
    required this.userRepository,
    required this.secureStorage,
  }) : super(UserModelLoading()) {
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
      // write token to secureStorage
      await Future.wait([
        secureStorage.write(key: ACCESS_TOKEN_KEY, value: token.accessToken),
        secureStorage.write(key: REFRESH_TOKEN_KEY, value: token.refreshToken)
      ]);

      if (user == null) {
        throw Exception("유저 정보가 없습니다.");
      }

      state = user;
    } catch (e) {
      state = null;
    }
  }

  Future<void> updateProfile(
      Map<String, dynamic> profile, MultipartFile? profileImg) async {
    final result = await userRepository.updateProfile(
      profile: profile,
      file: profileImg == null ? [] : [profileImg],
    );

    final pState = state as UserModel;

    state = pState.changeProfile(
      nickname: result.nickname,
      profileImg: result.profileImg,
    );
  }

  Future<String> getAccessTokenByRefreshToken({
    String? refreshToken,
  }) async {
    refreshToken ??= await secureStorage.read(key: REFRESH_TOKEN_KEY);

    final token = await authRepository.getAccessTokenByRefreshToken(
      refreshToken: refreshToken!,
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

  loginWithTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final user = await userRepository.getMe(
        accessTokenWithBearer: "Bearer $accessToken",
      );

      if (user == null) {
        throw Exception("유저 정보가 없습니다.");
      }

      // secureStorage write
      await Future.wait([
        secureStorage.write(key: ACCESS_TOKEN_KEY, value: accessToken),
        secureStorage.write(key: REFRESH_TOKEN_KEY, value: refreshToken)
      ]);
      state = user;
    } catch (e) {
      state = UserModelError(message: "로그인 실패");
      return;
    }
  }

  logout() async {
    await userRepository.logout();
    await secureStorage.deleteAll();

    state = null;
  }

  logoutWithoutRequest() async {
    await secureStorage.deleteAll();
    state = null;
  }

  revokeAccount() async {
    if (state == null) {
      return;
    }
    final pState = state as UserModel;
    if (pState.provider == "kakao") {
      await userRepository.deleteKakaoUser();
    } else if (pState.provider == "google") {
      await userRepository.deleteGoogleUser();
    } else {
      await userRepository.deleteEmailUser();
    }

    await secureStorage.deleteAll();
    state = null;
  }
}
