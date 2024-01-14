import 'package:client/chat/model/model_with_from_json.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/utils/data_utils.dart';

part 'chat_room_model.g.dart';

@JsonSerializable()
class ChatRoomModel implements IModelWithId, IModelWithFromJson {
  // id : 유일 아이디 값
  @override
  @JsonKey(name: '_id')
  final String id;
  // title : 제목
  final String title;
  // thumbnail : 썸네일 -> S3에 저장된 이미지, vid 의 경로
  @JsonKey(
    fromJson: DataUtils.listPathsToUrls,
  )
  final List<String> thumbnail;
  // max : 최대 인원
  final int max;
  // currentUserCount : 현재 인원
  final int currentUserCount;
  // lastChat : 마지막 메시지
  final String? lastChat;
  // createdAt : 생성 일자
  // read 해오는 경우 서버에서 UTC로 보내주기 때문에 local time zone으로 변경
  // write 경우는 따로 파싱을 하지 않음 -> 서버에서 저장 시 MongoDB가 자체적으로 UTC로 변경하여 저장
  @JsonKey(
    defaultValue: null,
    fromJson: DataUtils.toLocalTimeZone,
  )
  final DateTime? lastChatCreatedAt;

  ChatRoomModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.max,
    required this.currentUserCount,
    required this.lastChat,
    required this.lastChatCreatedAt,
  });

  // copyWith({
  //   String? id,
  //   String? title,
  //   String? writer,
  //   String? weather,
  //   List<String>? hashtags,
  //   String? thumbnail,
  //   DiaryCategory? category,
  //   DateTime? createdAt,
  //   int? likeCount,
  //   bool? isLike,
  // }) {
  //   return DiaryModel(
  //     id: id ?? this.id,
  //     title: title ?? this.title,
  //     writer: writer ?? this.writer,
  //     weather: weather ?? this.weather,
  //     hashtags: hashtags ?? this.hashtags,
  //     thumbnail: thumbnail ?? this.thumbnail,
  //     category: category ?? this.category,
  //     createdAt: createdAt ?? this.createdAt,
  //     likeCount: likeCount ?? this.likeCount,
  //     isLike: isLike ?? this.isLike,
  //   );
  // }

  factory ChatRoomModel.fromObject(Object? o) =>
      ChatRoomModel.fromJson(o as Map<String, dynamic>);

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomModelToJson(this);
}
