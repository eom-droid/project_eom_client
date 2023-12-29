import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/repository/base_pagination_repository.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 페이지네이션 요청을 위한 정보 클래스
class _PaginationInfo {
  // fetch 해올 갯수
  final int fetchCount;
  // 추가로 데이터 더 가져올지의 여부
  final bool fetchMore;
  // 강제로 다시 로딩할지의 여부
  final bool forceRefetch;

  _PaginationInfo({
    this.fetchCount = 10,
    this.fetchMore = false,
    this.forceRefetch = false,
  });
}

class PaginationNotifier<T extends IModelWithId,
        U extends IBasePaginationRepository<T>>
    extends StateNotifier<CursorPaginationBase> {
  final U repository;
  late final String randomKey;

  PaginationNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    Uuid uuid = const Uuid();
    randomKey = uuid.v4();
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 10,
    // 추가로 데이터 더 가져오기
    // ture - 추가로 데이터 가져오기
    // false - 새로고침(현재 상태를 덮어씌움)
    bool fetchMore = false,
    // 강제로 다시 로딩하기
    // true - CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    EasyThrottle.throttle(
      randomKey,
      const Duration(seconds: 3),
      () => _throttlePagination(
        _PaginationInfo(
          fetchCount: fetchCount,
          fetchMore: fetchMore,
          forceRefetch: forceRefetch,
        ),
      ),
    );
  }

  _throttlePagination(_PaginationInfo info) async {
    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;

    try {
      // 5가지 상태
      // 1. CursorPagination - 정상적인 데이터 존재 상태
      // 2. CursorPaginationLoading - 로딩 중(현재 캐시 없음)
      // 3. CursorPaginationError - 에러 존재 상태
      // 4. CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때(맨 상단에서 재요청)
      // 5. CursorPaginationMoreLoading - 추가로 데이터를 가져올때 paginate상태임(맨 하단에서 재요청)

      // 바로 반환하는 상황
      // 1) hasMore이 false인 경우(기존 상태에서 이미 다음 데이터가 없다는 값을 가지고 있음)
      // 2) 로딩중 - fetchMore : true
      //    fetchMore이 false -> 새로고침의 의도를 가지고 있음
      // 2) 이외의 상황

      // 1번 반환 상황
      // 현재 값이 있는 상태이며(CusroPagination) 강제 refetch가 아닌 경우
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        // 데이터가 더이상 없는 경우
        if (!pState.meta.hasMore) {
          return;
        }
      }

      // 2번 반환 상황
      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;
      // 추가로 데이터를 가져오는 상황인데 이미 한번 요청해서 로딩중인 경우
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // 3번 반환 상황
      // count를 넣어줘야됨
      PaginationParams? paginationParams;

      // fetchMore 상황
      // 데이터를 추가로 더 가져오기
      if (fetchMore) {
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );
        paginationParams =
            generateParams(pState.data.lastOrNull, fetchCount, fetchMore);
      }
      // 처음부터 데이터를 가져오는 상황
      else {
        // 만약 데이터가 현재 있다면
        // 기존 데이터를 캐싱한 상태에서 Fetch(API 요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 현재 데이터가 없다면
        // 로딩 상태임을 반환함
        else {
          state = CursorPaginationLoading();
        }
        paginationParams = generateParams(null, fetchCount, fetchMore);
      }

      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      // 현재 값이 존재하고 값을 추가적으로 가지고 오는 경우
      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore<T>;

        // 뒤에 추가하기
        // Meta 포함
        state = resp.copyWith(data: [
          ...pState.data,
          ...resp.data,
        ]);
      }
      // 현재 값이 존재하지 않고 fetch를 해오는 경우는
      // 현재 state에 덮어씌우기
      else {
        state = resp;
      }
    } catch (e) {
      print(e);
      state = CursorPaginationError(message: '데이터 가져오기 실패');
    }
  }

  PaginationParams generateParams(
    T? pState,
    int fetchCount,
    bool fetchMore,
  ) {
    if (pState == null) {
      return PaginationParams(
        count: fetchCount,
      );
    }
    final value = pState;
    return PaginationParams(
      after: fetchMore ? value.id : null,
      count: fetchCount,
    );
  }
}

// import 'package:debounce_throttle/debounce_throttle.dart';

// // 페이지네이션 요청을 위한 정보 클래스
// class _PaginationInfo {
//   // fetch 해올 갯수
//   final int fetchCount;
//   // 추가로 데이터 더 가져올지의 여부
//   final bool fetchMore;
//   // 강제로 다시 로딩할지의 여부
//   final bool forceRefetch;

//   _PaginationInfo({
//     this.fetchCount = 10,
//     this.fetchMore = false,
//     this.forceRefetch = false,
//   });
// }

// class PaginationProvider<T extends IModelWithId,
//         U extends IBasePaginationRepository<T>>
//     extends StateNotifier<CursorPaginationBase> {
//   final U repository;
//   final paginationThrottle = Throttle(
//     const Duration(seconds: 3),
//     initialValue: _PaginationInfo(),
//     checkEquality: false,
//   );

//   PaginationProvider({
//     required this.repository,
//   }) : super(CursorPaginationLoading()) {
//     paginate();
//     paginationThrottle.values.listen((state) {
//       _throttlePagination(state);
//     });
//   }

//   Future<void> paginate({
//     int fetchCount = 1,
//     // 추가로 데이터 더 가져오기
//     // ture - 추가로 데이터 가져오기
//     // false - 새로고침(현재 상태를 덮어씌움)
//     bool fetchMore = false,
//     // 강제로 다시 로딩하기
//     // true - CursorPaginationLoading()
//     bool forceRefetch = false,
//   }) async {
//     paginationThrottle.setValue(_PaginationInfo(
//       fetchCount: fetchCount,
//       fetchMore: fetchMore,
//       forceRefetch: forceRefetch,
//     ));
//   }

//   _throttlePagination(_PaginationInfo info) async {
//     final fetchCount = info.fetchCount;
//     final fetchMore = info.fetchMore;
//     final forceRefetch = info.forceRefetch;

//     try {
//       // 5가지 상태
//       // 1. CursorPagination - 정상적인 데이터 존재 상태
//       // 2. CursorPaginationLoading - 로딩 중(현재 캐시 없음)
//       // 3. CursorPaginationError - 에러 존재 상태
//       // 4. CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때(맨 상단에서 재요청)
//       // 5. CursorPaginationMoreLoading - 추가로 데이터를 가져올때 paginate상태임(맨 하단에서 재요청)

//       // 바로 반환하는 상황
//       // 1) hasMore이 false인 경우(기존 상태에서 이미 다음 데이터가 없다는 값을 가지고 있음)
//       // 2) 로딩중 - fetchMore : true
//       //    fetchMore이 false -> 새로고침의 의도를 가지고 있음
//       // 2) 이외의 상황

//       // 1번 반환 상황
//       // 현재 값이 있는 상태이며(CusroPagination) 강제 refetch가 아닌 경우
//       if (state is CursorPagination && !forceRefetch) {
//         final pState = state as CursorPagination;

//         // 데이터가 더이상 없는 경우
//         if (!pState.meta.hasMore) {
//           return;
//         }
//       }

//       // 2번 반환 상황
//       final isLoading = state is CursorPaginationLoading;
//       final isRefetching = state is CursorPaginationRefetching;
//       final isFetchingMore = state is CursorPaginationFetchingMore;
//       // 추가로 데이터를 가져오는 상황인데 이미 한번 요청해서 로딩중인 경우
//       if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
//         return;
//       }

//       // 3번 반환 상황
//       // count를 넣어줘야됨
//       PaginationParams? paginationParams;

//       // fetchMore 상황
//       // 데이터를 추가로 더 가져오기
//       if (fetchMore) {
//         final pState = state as CursorPagination<T>;

//         state = CursorPaginationFetchingMore(
//           meta: pState.meta,
//           data: pState.data,
//         );
//         paginationParams =
//             generateParams(pState.data.lastOrNull, fetchCount, fetchMore);
//       }
//       // 처음부터 데이터를 가져오는 상황
//       else {
//         // 만약 데이터가 현재 있다면
//         // 기존 데이터를 캐싱한 상태에서 Fetch(API 요청)를 진행
//         if (state is CursorPagination && !forceRefetch) {
//           final pState = state as CursorPagination<T>;

//           state = CursorPaginationRefetching(
//             meta: pState.meta,
//             data: pState.data,
//           );
//         }
//         // 현재 데이터가 없다면
//         // 로딩 상태임을 반환함
//         else {
//           state = CursorPaginationLoading();
//         }
//         paginationParams = generateParams(null, fetchCount, fetchMore);
//       }

//       final resp = await repository.paginate(
//         paginationParams: paginationParams,
//       );

//       // 현재 값이 존재하고 값을 추가적으로 가지고 오는 경우
//       if (state is CursorPaginationFetchingMore) {
//         final pState = state as CursorPaginationFetchingMore<T>;

//         // 뒤에 추가하기
//         // Meta 포함
//         state = resp.copyWith(data: [
//           ...pState.data,
//           ...resp.data,
//         ]);
//       }
//       // 현재 값이 존재하지 않고 fetch를 해오는 경우는
//       // 현재 state에 덮어씌우기
//       else {
//         state = resp;
//       }
//     } catch (e) {
//       print(e);
//       state = CursorPaginationError(message: '데이터 가져오기 실패');
//     }
//   }

//   PaginationParams generateParams(
//     T? pState,
//     int fetchCount,
//     bool fetchMore,
//   ) {
//     if (pState == null) {
//       return PaginationParams(
//         count: fetchCount,
//       );
//     }
//     final value = pState as IModelWithId;
//     return PaginationParams(
//       after: fetchMore ? value.id : null,
//       count: fetchCount,
//     );
//   }
// }
