import 'package:client/auth/model/token_model.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const SET_COOKIE_SPLIT_PATTERN = "; ";

final authRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  String ip = dotenv.env['IP']!;
  return AuthRepository(
    dio: dio,
    baseUrl: 'http://$ip/api/v1/auth',
  );
});

class AuthRepository {
  final String baseUrl;
  final Dio dio;

  AuthRepository({
    required this.baseUrl,
    required this.dio,
  });

  Future<TokenModel?> kakaoJoin(String kakaoToken) async {
    final resp = await dio.get('$baseUrl/join/app/kakao',
        options: Options(headers: {'Authorization': 'Bearer $kakaoToken'}));
    final refreshToken = _extractRefreshTokenFromCookie(resp);
    if (refreshToken == null) {
      return null;
    }

    final accessToken = resp.data['accessToken'];

    // secureStorage write

    return TokenModel(
      refreshToken: refreshToken,
      accessToken: accessToken,
    );
  }

  Future<TokenModel?> getAccessTokenByRefreshToken({
    required String refreshToken,
  }) async {
    final resp = await dio.get(
      '$baseUrl/access-token',
      options: Options(
        headers: {'Cookie': 'refreshToken=$refreshToken'},
      ),
    );

    final accessToken = resp.data['accessToken'];
    final refreshTokenFromCookie = _extractRefreshTokenFromCookie(resp);

    if (refreshTokenFromCookie == null) {
      return null;
    }

    return TokenModel(
      accessToken: accessToken,
      refreshToken: refreshTokenFromCookie,
    );
  }

  Future<bool> sendVerificationCode({
    required String email,
  }) async {
    try {
      final resp = await dio.get(
        '$baseUrl/join/email/verificationCode/send',
        data: {
          "email": email,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  String? _extractRefreshTokenFromCookie(Response<dynamic> resp) {
    final setCookie = resp.headers['set-cookie'];

    if (setCookie == null) {
      return null;
    }

    return setCookie[0]
        .split(SET_COOKIE_SPLIT_PATTERN)[0]
        .split("refreshToken=")[1];
  }

  Future<bool> join({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    try {
      final resp = await dio.post(
        '$baseUrl/join/email',
        data: {
          "email": email,
          "password": password,
          "verificationCode": verificationCode,
        },
      );

      return resp.statusCode == 200 ? true : false;
    } catch (e) {
      return false;
    }
  }

  Future<TokenModel?> emailLogin({
    required String email,
    required String password,
  }) async {
    final resp = await dio.post(
      '$baseUrl/login/email',
      data: {
        "email": email,
        "password": password,
      },
    );

    final accessToken = resp.data['accessToken'];
    final refreshTokenFromCookie = _extractRefreshTokenFromCookie(resp);

    if (refreshTokenFromCookie == null) {
      return null;
    }

    return TokenModel(
      accessToken: accessToken,
      refreshToken: refreshTokenFromCookie,
    );
  }

  Future<bool> resetPassword({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    try {
      final resp = await dio.post(
        '$baseUrl/password/reset',
        data: {
          "email": email,
          "password": password,
          "verificationCode": verificationCode,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
