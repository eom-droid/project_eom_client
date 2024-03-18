// abstract class UserRepository

import 'package:client/common/dio/dio.dart';
import 'package:client/user/model/user_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'dart:convert';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.read(dioProvider);

  String ip = dotenv.env['IP']!;

  return UserRepository(dio, baseUrl: 'http://$ip/api/v1/user');
});

@RestApi()
abstract class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  // getMe를 진행할때는 accessToken이 storage에 저장되어있지 않은 상태임
  // 따라서 따로 넣어주는중
  @GET('/me')
  Future<UserModel?> getMe({
    @Header('authorization') required String accessTokenWithBearer,
  });

  @PATCH("/me/profile")
  @Headers({
    'accessToken': 'true',
  })
  @MultiPart()
  Future<UserModel> updateProfile({
    // @Body() required Map<String, dynamic> profile,
    @Part(name: "profile") required Map<String, dynamic> profile,
    @Part(name: "file") required List<MultipartFile> file,
  });

  @DELETE("/me")
  @Headers({
    'accessToken': 'true',
  })
  Future<void> deleteUser();
}
