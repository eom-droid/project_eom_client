import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/music/model/music_model.dart';
import 'package:client/music/repository/music_repository.dart';

final musicDetailProvider = Provider.family<MusicModel?, String>((ref, id) {
  final state = ref.watch(musicProvider);

  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhereOrNull((element) => element.id == id);
});

final musicProvider =
    StateNotifierProvider<MusicStateNotifier, CursorPaginationBase>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return MusicStateNotifier(
    repository: musicRepository,
  );
});

class MusicStateNotifier
    extends PaginationProvider<MusicModel, MusicRepository, PaginationParams> {
  MusicStateNotifier({
    required super.repository,
  });
}
