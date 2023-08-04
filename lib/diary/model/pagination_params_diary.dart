import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/pagination_params.dart';

part 'pagination_params_diary.g.dart';

// 추후 카테고리 지우기
@JsonSerializable()
class PaginationParamsDiary extends PaginationParamsBase {
  final String? category;
  final DateTime? postDT;

  const PaginationParamsDiary({
    super.count,
    this.category,
    this.postDT,
  });

  PaginationParamsDiary copyWith({
    int? count,
    String? category,
    DateTime? postDT,
  }) {
    return PaginationParamsDiary(
      count: count ?? this.count,
      category: category ?? this.category,
      postDT: postDT ?? this.postDT,
    );
  }

  Map<String, dynamic> toJson() => _$PaginationParamsDiaryToJson(this);
}
