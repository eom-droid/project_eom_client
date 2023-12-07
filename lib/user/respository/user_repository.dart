// abstract class UserRepository

import 'package:client/common/dio/dio.dart';
import 'package:client/user/model/user_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.read(dioProvider);

  String ip = dotenv.env['IP']!;

  return UserRepository(dio, baseUrl: 'http://$ip/api/v1/user');
});

@RestApi()
abstract class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  @GET('/me')
  Future<UserModel?> getMe({
    @Header('authorization') required String accessTokenWithBearer,
  });
}








// // abstract class UserRepository

// import 'package:client/common/dio/dio.dart';
// import 'package:client/user/model/user_model.dart';
// import 'package:dio/dio.dart' hide Headers;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final userRepositoryProvider = Provider<UserRepository>((ref) {
//   final dio = ref.read(dioProvider);

//   String ip = dotenv.env['IP']!;

//   return UserRepository(dio: dio, baseUrl: 'http://$ip/api/v1/user');
// });


// // userRepository에 retrofit을 사용하지 않은 이유
// // getMe를 진행하는 경우는 userProvider에서 상태값이 userWithTokenModelLoading일때이기 때문에
// // accessToken의 값을 가져오지 못한다.
// class UserRepository {
//   final String baseUrl;
//   final Dio dio;

//   UserRepository({
//     required this.dio,
//     required this.baseUrl,
//   });

//   Future<UserModel?> getMe({
//     required String accessToken,
//   }) async {
//     final resp = await dio.get('$baseUrl/me', options: );

//     print(UserModel.fromJson(resp.data));
//     return null;

//     // return dio.get('$baseUrl/me').then((value) => UserModel.fromJson(value.data));
//   }
// }
