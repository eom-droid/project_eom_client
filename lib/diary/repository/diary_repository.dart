// final diaryRepositoryProvider = Provider<>

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/repository/base_pagination_repository.dart';
import 'package:client/diary/model/diary_detail_model.dart';
import 'package:client/diary/model/diary_model.dart';
import 'package:client/diary/model/pagination_params_diary.dart';

import 'package:retrofit/retrofit.dart';

part 'diary_repository.g.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final dio = ref.read(dioProvider);

  String ip = dotenv.env['IP']!;

  return DiaryRepository(dio, baseUrl: 'http://$ip/api/v1/diaries');
});

@RestApi()
abstract class DiaryRepository
    implements IBasePaginationRepository<DiaryModel, PaginationParamsDiary> {
  factory DiaryRepository(Dio dio, {String baseUrl}) = _DiaryRepository;

  // diary pagination는
  @override
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<DiaryModel>> paginate({
    @Queries()
        PaginationParamsDiary? paginationParams = const PaginationParamsDiary(),
  });

  @GET('/{id}/detail')
  @Headers({
    'accessToken': 'true',
  })
  Future<DiaryDetailModel> getDiaryDetail({
    @Path() required String id,
  });
}
