import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/diary/model/diary_detail_model.dart';
import 'package:client/diary/model/diary_model.dart';
import 'package:client/diary/model/pagination_params_diary.dart';
import 'package:client/diary/repository/diary_repository.dart';

final diaryDetailProvider = Provider.family<DiaryModel?, String>((ref, id) {
  final state = ref.watch(diaryProvider);

  // 레스토랑 프로젝트에서 해당 줄을 추가하였는데 이유가 뭔지 궁금하네.....
  // 정상적으로 데이터가 있는 상태가 아니라면 null을 리턴하여 circularProgressIndicator를 보여준다.
  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhereOrNull((element) => element.id == id);
});

final diaryProvider =
    StateNotifierProvider<DiaryStateNotifier, CursorPaginationBase>((ref) {
  final diaryRepository = ref.watch(diaryRepositoryProvider);
  return DiaryStateNotifier(
    repository: diaryRepository,
  );
});

class DiaryStateNotifier extends PaginationProvider<DiaryModel, DiaryRepository,
    PaginationParamsDiary> {
  DiaryStateNotifier({
    required super.repository,
  });

  void getDetail({
    required String id,
  }) async {
    // 만약 데이터가 없는 상태라면
    // 데이터를 가져오는 함수를 실행한다.
    if (state is! CursorPagination) {
      await paginate();
    }

    // state가 Cursorpagination이 아닐경우 그냥 리턴
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final selectedDiary =
        pState.data.firstWhereOrNull((element) => element.id == id);

    // 만약 데이터가 이미 캐시에 존재한다면 그냥 리턴
    if (selectedDiary != null && selectedDiary is DiaryDetailModel) {
      return;
    }

    // 추후 데이터의 저장 형태에 따라서 다르게 처리할 예정
    final resp = await repository.getDiaryDetail(id: id);

    // [DiaryModel(1), DiaryModel(2), DiaryModel(3)]
    // 요청 id: 10
    // list.where((e)=> e.id== 10) 데이터 X
    // 데이터가 없을때는 그냥 캐시의 끝에다가 데이터를 추가해버린다.
    // [DiaryModel(1), DiaryModel(2), DiaryModel(3),DiaryDetailModel(10)]
    // 이렇게 접근하는 경우는 없을거라서 없을것으로 예상됨
    if (pState.data.where((element) => element.id == id).isEmpty) {
      state = pState.copyWith(
        data: <DiaryModel>[
          ...pState.data,
          resp,
        ],
      );
    } else {
      // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
      // id : 2인 친구를 Detail모델로 가져와라
      // getDetail(id:2)
      // [RestaurantModel(1), RestaurantDetailModel(2), RestaurantModel(3)]
      state = pState.copyWith(
        data: pState.data
            .map<DiaryModel>(
              (e) => e.id == id ? resp : e,
            )
            .toList(),
      );
    }
  }
}
