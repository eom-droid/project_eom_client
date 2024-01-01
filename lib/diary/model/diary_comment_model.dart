import 'package:client/common/model/model_with_id.dart';
import 'package:client/user/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/utils/data_utils.dart';

part 'diary_comment_model.g.dart';

@JsonSerializable()
class DiaryCommentModel implements IModelWithId {
  // id : 유일 아이디 값
  @override
  @JsonKey(name: '_id')
  final String id;
  // writer : 작성자
  final UserModel? writer;
  // content : 내용
  final String content;
  // createdAt : 생성 일자
  // read 해오는 경우 서버에서 UTC로 보내주기 때문에 local time zone으로 변경
  // write 경우는 따로 파싱을 하지 않음 -> 서버에서 저장 시 MongoDB가 자체적으로 UTC로 변경하여 저장
  @JsonKey(
    defaultValue: null,
    fromJson: DataUtils.toLocalTimeZone,
  )
  final DateTime createdAt;
  // likeCount : 좋아요 개수
  final int likeCount;
  // isLike : 좋아요 여부
  final bool isLike;

  DiaryCommentModel({
    required this.id,
    this.writer,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLike,
  });

  copyWith({
    String? id,
    UserModel? writer,
    String? content,
    DateTime? createdAt,
    int? likeCount,
    bool? isLike,
  }) {
    return DiaryCommentModel(
      id: id ?? this.id,
      writer: writer ?? this.writer,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLike: isLike ?? this.isLike,
    );
  }

  factory DiaryCommentModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryCommentModelToJson(this);
}

@JsonSerializable()
class DiaryCommentReqModel {
  final String content;

  DiaryCommentReqModel({
    required this.content,
  });

  factory DiaryCommentReqModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryCommentReqModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryCommentReqModelToJson(this);
}
