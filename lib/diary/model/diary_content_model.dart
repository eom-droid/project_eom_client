import 'package:json_annotation/json_annotation.dart';

part 'diary_content_model.g.dart';

@JsonSerializable()
class DiaryContentReqModel {
  final String content;

  DiaryContentReqModel({
    required this.content,
  });

  factory DiaryContentReqModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryContentReqModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryContentReqModelToJson(this);
}
