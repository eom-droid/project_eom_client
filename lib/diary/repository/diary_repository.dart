// final diaryRepositoryProvider = Provider<>

import 'package:client/common/model/pagination_params.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/repository/base_pagination_repository.dart';
import 'package:client/diary/model/diary_detail_model.dart';
import 'package:client/diary/model/diary_model.dart';

import 'package:retrofit/retrofit.dart';

part 'diary_repository.g.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final dio = ref.read(dioProvider);

  final String baseUrl = dotenv.env['REST_API_BASE_URL']!;

  return DiaryRepository(dio, baseUrl: '$baseUrl/api/v1/diaries');
});

@RestApi()
abstract class DiaryRepository
    implements IBasePaginationRepository<DiaryModel> {
  factory DiaryRepository(Dio dio, {String baseUrl}) = _DiaryRepository;

  // diary pagination는
  @override
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<DiaryModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  @GET('/{id}/detail')
  @Headers({
    'accessToken': 'true',
  })
  Future<DiaryDetailModel> getDiaryDetail({
    @Path() required String id,
  });

  @POST('/{id}/like')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> createLikeDiary({
    @Path() required String id,
  });

  @DELETE('/{id}/like')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> deleteLikeDiary({
    @Path() required String id,
  });
}
