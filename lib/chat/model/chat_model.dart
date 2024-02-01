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
class ChatTempModel extends ChatModel {
  final String tempMessageId;
  ChatTempModel({
    required super.id,
    required super.userId,
    required super.content,
    required super.createdAt,
    required this.tempMessageId,
  });
  ChatModel parseToChatModel() {
    return ChatModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    );
  }

  ChatModel parseToChatFailedModel(String error) {
    return ChatFailedModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
      tempMessageId: tempMessageId,
      error: error,
    );
  }

  factory ChatTempModel.fromObject(Object? o) =>
      ChatTempModel.fromJson(o as Map<String, dynamic>);

  factory ChatTempModel.fromJson(Map<String, dynamic> json) =>
      _$ChatTempModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatTempModelToJson(this);
}

@JsonSerializable()
class ChatFailedModel extends ChatModel {
  final String error;
  final String tempMessageId;
  ChatFailedModel({
    required super.id,
    required super.userId,
    required super.content,
    required super.createdAt,
    required this.tempMessageId,
    required this.error,
  });
  @override
  ChatModel parseToChatModel() {
    return ChatModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    );
  }

  ChatModel parseToChatModelTemp(String tempMessageId) {
    return ChatTempModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
      tempMessageId: tempMessageId,
    );
  }

  factory ChatFailedModel.fromObject(Object? o) =>
      ChatFailedModel.fromJson(o as Map<String, dynamic>);

  factory ChatFailedModel.fromJson(Map<String, dynamic> json) =>
      _$ChatFailedModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatFailedModelToJson(this);
}
