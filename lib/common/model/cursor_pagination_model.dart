import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

// abstract class 생성
sealed class CursorPaginationBase {}

// 에러 상태의 class
class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({
    required this.message,
  });
}

// 로딩 상태의 class
class CursorPaginationLoading extends CursorPaginationBase {}

// 데이터 상태의 class
// genericArgumentFactories 제너릭으로 값의 형태를 정할 수 있음
@JsonSerializable(genericArgumentFactories: true)
class CursorPagination<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  CursorPagination copyWith({
    CursorPaginationMeta? meta,
    List<T>? data,
  }) {
    return CursorPagination<T>(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }

  // fromJsonT는 this class에 대한 fromJson을 진행할때
  // 실질적인 fromJson은 T 모델에 해당하는 fromJson을 진행하도록 함
  factory CursorPagination.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  CursorPaginationMeta copyWith({
    int? count,
    bool? hasMore,
  }) {
    return CursorPaginationMeta(
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

//////////////////이 아래 두개 class는 왜 cursorPagination class를 상속받을까?////////////////
/// 이유 : Refetching이나 FetchingMore은 현재 상태값이 있는 상태에서(CursorPagination)이 인스턴스화 되어있는 상태에서 진행되기 때문
// 새로고침 할때
// instance is CursorPagination; -> true
// instance is CursorPaginationBase; -> true

// refetching은 새로고침 상태
class CursorPaginationRefetching<T> extends CursorPagination<T> {
  CursorPaginationRefetching({
    required super.meta,
    required super.data,
  });
}

// 리스트의 맨 아래로 내려서
// 추가 데이터를 요청하는상태
class CursorPaginationFetchingMore<T> extends CursorPagination<T> {
  CursorPaginationFetchingMore({
    required super.meta,
    required super.data,
  });
}
