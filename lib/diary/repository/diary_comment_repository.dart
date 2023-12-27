// // final diaryRepositoryProvider = Provider<>

// import 'package:client/common/model/pagination_params.dart';
// import 'package:client/diary/model/diary_comment_model.dart';
// import 'package:dio/dio.dart' hide Headers;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:client/common/dio/dio.dart';
// import 'package:client/common/model/cursor_pagination_model.dart';
// import 'package:client/common/repository/base_pagination_repository.dart';

// import 'package:retrofit/retrofit.dart';

// part 'diary_comment_repository.g.dart';

// final diaryCommentRepositoryProvider = Provider<DiaryCommentRepository>((ref) {
//   final dio = ref.read(dioProvider);

//   String ip = dotenv.env['IP']!;

//   return DiaryCommentRepository(dio, baseUrl: 'http://$ip/api/v1/diaries');
// });

// @RestApi()
// abstract class DiaryCommentRepository
//     implements IBasePaginationRepositoryWithId<DiaryCommentModel> {
//   factory DiaryCommentRepository(Dio dio, {String baseUrl}) =
//       _DiaryCommentRepository;

//   static const subPath = '/{id}/comment';

//   @override
//   @GET(subPath)
//   @Headers({
//     'accessToken': 'true',
//   })
//   Future<CursorPagination<DiaryCommentModel>> paginate({
//     @Path() required String id,
//     @Queries() PaginationParams? paginationParams = const PaginationParams(),

//   });

//   @POST(subPath)
//   @Headers({
//     'accessToken': 'true',
//   })
//   Future<void> createComment({
//     @Path() required String id,
//     @Body() required DiaryCommentReqModel content,
//   });

//   @PATCH(subPath)
//   @Headers({
//     'accessToken': 'true',
//   })
//   Future<void> patchComment({
//     @Path() required String id,
//     @Body() required DiaryCommentReqModel content,
//   });
// }

// final diaryRepositoryProvider = Provider<>

import 'package:client/common/model/pagination_params.dart';
import 'package:client/diary/model/diary_comment_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/repository/base_pagination_repository.dart';

import 'package:retrofit/retrofit.dart';

part 'diary_comment_repository.g.dart';

final diaryCommentRepositoryProvider =
    Provider.family<DiaryCommentRepository, String>((ref, diaryId) {
  final dio = ref.read(dioProvider);

  String ip = dotenv.env['IP']!;

  return DiaryCommentRepository(dio,
      baseUrl: 'http://$ip/api/v1/diaries/$diaryId/comment');
});

@RestApi()
abstract class DiaryCommentRepository
    implements IBasePaginationRepository<DiaryCommentModel> {
  factory DiaryCommentRepository(Dio dio, {String baseUrl}) =
      _DiaryCommentRepository;

  @override
  @GET('')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<DiaryCommentModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  @POST('')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> createComment({
    @Path() required String id,
    @Body() required DiaryCommentReqModel content,
  });

  @PATCH('')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> patchComments({
    @Body() required DiaryCommentReqModel content,
  });
}
