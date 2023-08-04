import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/repository/base_pagination_repository.dart';

import 'package:client/music/model/music_model.dart';
import 'package:retrofit/retrofit.dart';

part 'music_repository.g.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final dio = ref.read(dioProvider);
  String ip = dotenv.env['IP']!;
  return MusicRepository(dio, baseUrl: 'http://$ip/api/v1/musics');
});

@RestApi()
abstract class MusicRepository
    implements IBasePaginationRepository<MusicModel, PaginationParams> {
  factory MusicRepository(Dio dio, {String baseUrl}) = _MusicRepository;

  // music pagination는
  @override
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<MusicModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
}
