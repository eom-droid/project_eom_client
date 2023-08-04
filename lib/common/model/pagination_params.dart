import 'package:json_annotation/json_annotation.dart';

part 'pagination_params.g.dart';

class PaginationParamsBase {
  final int? count;

  const PaginationParamsBase({
    this.count,
  });
}

@JsonSerializable()
class PaginationParams extends PaginationParamsBase {
  final String? after;

  const PaginationParams({
    super.count,
    this.after,
  });
  PaginationParams copyWith({
    int? count,
    String? after,
  }) =>
      PaginationParams(
        after: after ?? this.after,
        count: count ?? this.count,
      );

  Map<String, dynamic> toJson() => _$PaginationParamsToJson(this);
}
