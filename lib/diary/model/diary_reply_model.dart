import 'package:client/common/model/model_with_id.dart';
import 'package:client/user/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/utils/data_utils.dart';

part 'diary_reply_model.g.dart';

@JsonSerializable()
class DiaryReplyModel implements IModelWithId {
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

  DiaryReplyModel({
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
    return DiaryReplyModel(
      id: id ?? this.id,
      writer: writer ?? this.writer,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLike: isLike ?? this.isLike,
    );
  }

  factory DiaryReplyModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryReplyModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryReplyModelToJson(this);
}
