import 'package:client/common/const/data.dart';
import 'package:client/common/provider/secure_storage.dart';
import 'package:client/user/provider/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storage = ref.read(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(ref: ref, storage: storage),
  );
  return dio;
});

// intercepter로 할수 있는 기능
class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;
  final String baseUrl = dotenv.env['REST_API_BASE_URL']!;

  CustomInterceptor({
    required this.ref,
    required this.storage,
  });

  // 1) 요청을 보낼떄
  // 요청이 보내질떄마다
  // 만약 요청의 Header에 accessToken: true 라는 값이 있다면
  // 실제 토큰을 가져와서(storage에서) authorize에 'Bearer $token' 이라는 값으로
  // 헤더를 변경한다.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');
      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      //  실제 토큰으로 대체
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    if (options.headers['refreshToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('refreshToken');
      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      //  실제 토큰으로 대체
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    // 요청은 이줄에서
    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401에러가 났을때(status code)
    // 토큰을 재발급 받는 시도를하고 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을한다.
    print(
        '[ERROR] [${err.requestOptions.method}] [${err.response?.statusCode}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 아예 없다면
    // 당연히 에러를 던진다.
    if (refreshToken == null) {
      // 에러를 던질때는 handler.reject(err)를 사용한다.
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh =
        err.requestOptions.path == '/api/v1/auth/access-token';

    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final resp = await dio.get(
          '$baseUrl/api/v1/auth/access-token',
          options: Options(
            headers: {
              'authorization': 'Bearer $refreshToken',
            },
          ),
        );

        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        // 토큰 변경하기
        options.headers.addAll({'authorization': 'Bearer $accessToken'});

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // 요청 재전송
        final response = await dio.fetch(options);

        // 성공으로 취급함
        return handler.resolve(response);
      } on DioError catch (e) {
        // circular dependency error
        // A, B
        // A -> B의 친구
        // B -> A의 친구
        // A-> B -> A ..... 무한반복
        // userMeProvider -> dioProvider -> userMeProvider -> dioProvider
        // 해결방법은 userMeProvider를 접근하여 Logout을 하는 형태가 아닌
        // 그것보다 상위에 있는 authProvider에서 logout을 하는 형태로 변경한다.
        ref.read(userProvider.notifier).logoutWithoutRequest();

        return handler.reject(e);
      }
    }

    return handler.reject(err);
  }
}
