import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/utils/data_utils.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel implements IModelWithId {
  // id : 유일 아이디 값
  @override
  @JsonKey(name: '_id')
  final String id;
  // userId : 유저 아이디
  final String userId;
  // content : 내용
  final String content;
  // createdAt : 생성시간
  @JsonKey(
    defaultValue: null,
    fromJson: DataUtils.toLocalTimeZone,
  )
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory ChatModel.fromObject(Object? o) =>
      ChatModel.fromJson(o as Map<String, dynamic>);

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

@JsonSerializable()
class ChatModelTemp extends ChatModel {
  ChatModelTemp({
    required super.id,
    required super.userId,
    required super.content,
    required super.createdAt,
  });
  ChatModel parseToChatModel() {
    return ChatModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    );
  }

  factory ChatModelTemp.fromObject(Object? o) =>
      ChatModelTemp.fromJson(o as Map<String, dynamic>);

  factory ChatModelTemp.fromJson(Map<String, dynamic> json) =>
      _$ChatModelTempFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatModelTempToJson(this);
}


// @JsonSerializable()
// class ChatModelFailed extends ChatModel {
//   ChatModelTemp({
//     required super.id,
//     required super.userId,
//     required super.content,
//     required super.createdAt,
//   });

//   factory ChatModelTemp.fromObject(Object? o) =>
//       ChatModelTemp.fromJson(o as Map<String, dynamic>);

//   factory ChatModelTemp.fromJson(Map<String, dynamic> json) =>
//       _$ChatModelTempFromJson(json);

//   @override
//   Map<String, dynamic> toJson() => _$ChatModelTempToJson(this);
// }


// @JsonSerializable()
// class TempChatModel extends ChatModel {
//   TempChatModel({
//     required super.id,
//     required super.userId,
//     required super.content,
//     required super.createdAt,
//   });

//   factory TempChatModel.fromObject(Object? o) =>
//       TempChatModel.fromJson(o as Map<String, dynamic>);

//   factory TempChatModel.fromJson(Map<String, dynamic> json) =>
//       _$TempChatModelFromJson(json);

//   @override
//   Map<String, dynamic> toJson() => _$TempChatModelToJson(this);
// }

