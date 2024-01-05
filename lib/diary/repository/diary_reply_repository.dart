import 'package:client/common/model/pagination_params.dart';
import 'package:client/diary/model/diary_content_model.dart';
import 'package:client/diary/model/diary_reply_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/repository/base_pagination_repository.dart';

import 'package:retrofit/retrofit.dart';

part 'diary_reply_repository.g.dart';

final diaryReplyRepositoryProvider =
    Provider.family<DiaryReplyRepository, String>((ref, commentId) {
  final dio = ref.read(dioProvider);

  String ip = dotenv.env['IP']!;

  return DiaryReplyRepository(
    dio,
    // diary의 id는 중요하지 않음 -> comment의 id가 중요함
    // 따라서 diaryId는 필요하지 않음
    baseUrl: 'http://$ip/api/v1/diaries/temp/comment/$commentId/reply',
  );
});

@RestApi()
abstract class DiaryReplyRepository
    implements IBasePaginationRepository<DiaryReplyModel> {
  factory DiaryReplyRepository(Dio dio, {String baseUrl}) =
      _DiaryReplyRepository;

  @override
  @GET('')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<DiaryReplyModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  @POST('')
  @Headers({
    'accessToken': 'true',
  })
  Future<String> createReply({
    @Path() required String id,
    @Body() required DiaryContentReqModel content,
  });

  @DELETE('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<String> deleteReply({
    @Path() required String id,
  });

  @PATCH('')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> patchReply({
    @Body() required DiaryContentReqModel content,
  });

  @POST('/{id}/like')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> createReplyLike({
    @Path() required String id,
  });

  @DELETE('/{id}/like')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> deleteReplyLike({
    @Path() required String id,
  });
}
