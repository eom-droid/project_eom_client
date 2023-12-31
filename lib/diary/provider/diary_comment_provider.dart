import 'package:client/diary/model/diary_comment_model.dart';
import 'package:client/diary/repository/diary_comment_repository.dart';
import 'package:easy_debounce/easy_debounce.dart';
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

  void toggleLike({
    required String commentId,
  }) {
    if (state is CursorPagination) {
      var pState = state as CursorPagination<DiaryCommentModel>;

      // 1. 선택된 diaryId를 찾는다.
      final selecteComment = pState.data.indexWhere(
        (element) => element.id == commentId,
      );

      // 2. 만약 선택된 diaryId가 없다면 그냥 리턴
      if (selecteComment == -1) {
        return;
      }

      // 3. 선택된 diaryId가 있다면 해당 데이터를 변경한다.
      pState.data[selecteComment] = pState.data[selecteComment].copyWith(
        isLike: !pState.data[selecteComment].isLike,
        likeCount: pState.data[selecteComment].likeCount +
            (pState.data[selecteComment].isLike ? -1 : 1),
      );

      // 4. 변경된 데이터를 적용한다.
      state = pState.copyWith(
        data: pState.data,
      );

      // 5. 서버에 좋아요를 요청한다.
      // 요청 시 현재의 상태가 0 -> 1 이면 좋아요를 생성
      // 요청 시 현재의 상태가 1 -> 0 이면 좋아요를 삭제
      EasyDebounce.debounce(
        'debounce/like/$commentId',
        const Duration(seconds: 1),
        () => pState.data[selecteComment].isLike
            ? repository.createLikeDiary(id: commentId)
            : repository.deleteLikeDiary(id: commentId),
      );
    }
  }
}
