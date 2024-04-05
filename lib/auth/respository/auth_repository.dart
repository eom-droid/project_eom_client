import 'package:client/auth/model/token_model.dart';
import 'package:client/common/dio/dio.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const SET_COOKIE_SPLIT_PATTERN = "; ";

final authRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);

  String baseUrl = dotenv.env['REST_API_BASE_URL']!;
  return AuthRepository(
    dio: dio,
    baseUrl: '$baseUrl/api/v1/auth',
  );
});

class AuthRepository {
  final String baseUrl;
  final Dio dio;

  AuthRepository({
    required this.baseUrl,
    required this.dio,
  });

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

  String? _extractRefreshTokenFromCookie(Response<dynamic> resp) {
    final setCookie = resp.headers['set-cookie'];

    if (setCookie == null) {
      return null;
    }

    return setCookie[0]
        .split(SET_COOKIE_SPLIT_PATTERN)[0]
        .split("refreshToken=")[1];
  }
}
