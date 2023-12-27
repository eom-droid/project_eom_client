import 'package:client/diary/model/diary_comment_model.dart';
import 'package:client/diary/repository/diary_comment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/provider/pagination_provider.dart';

// diaryCommentProvider를 사용하는 곳은 총 3가지 이다.
// get, delete, patch comment,
// 위 상황에서 diaryCommentProvider는 {diaryId : CursorPagination} 형태로 관리되어야 한다.
// 과거에 불러왔던

final diaryCommentProvider = StateNotifierProvider.family<
    DiaryCommentStateNotifier, CursorPaginationBase, String>((ref, diaryId) {
  final diaryRepository = ref.watch(diaryCommentRepositoryProvider(diaryId));
  return DiaryCommentManageStateNotifier(
    repository: diaryRepository,
  ).getCommentNotifier(diaryId: diaryId);
});

class DiaryCommentManageStateNotifier
    extends StateNotifier<Map<String, DiaryCommentStateNotifier>> {
  final DiaryCommentRepository repository;
  DiaryCommentManageStateNotifier({
    required this.repository,
  }) : super({});

  DiaryCommentStateNotifier getCommentNotifier({
    required String diaryId,
  }) {
    // 1. state에 id가 존재하는지 확인
    // 2. 존재한다면 해당 state를 리턴
    // 3. 존재하지 않는다면 새로운 state를 생성하여 리턴 -> 이때 paginating 같이 진행됨

    if (state.containsKey(diaryId)) {
      return state[diaryId]!;
    }

    state[diaryId] = DiaryCommentStateNotifier(
      repository: repository,
    );

    return state[diaryId]!;
  }
}

class DiaryCommentStateNotifier
    extends PaginationNotifier<DiaryCommentModel, DiaryCommentRepository> {
  DiaryCommentStateNotifier({
    required super.repository,
  });

  // state에 추가하여 관리해야됨
  createComment({
    required String diaryId,
    required String content,
  }) async {
    await repository.createComment(
      id: diaryId,
      content: DiaryCommentReqModel(
        content: content,
      ),
    );
  }
}
