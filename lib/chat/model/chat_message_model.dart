import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/utils/data_utils.dart';

part 'chat_message_model.g.dart';

@JsonSerializable()
class ChatMessageModel implements IModelWithId {
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

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // factory ChatMessageModel.fromObject(Object? o) =>
  //     ChatMessageModel.fromJson(o as Map<String, dynamic>);

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}

@JsonSerializable()
class ChatMessageTempModel extends ChatMessageModel {
  final String tempMessageId;
  final List<String> readUserIds;

  ChatMessageTempModel({
    required super.id,
    required super.userId,
    required super.content,
    required super.createdAt,
    required this.tempMessageId,
    required this.readUserIds,
  });
  ChatMessageModel parseToChatModel() {
    return ChatMessageModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    );
  }

  ChatMessageModel parseToChatFailedModel(String error) {
    return ChatMessageFailedModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
      tempMessageId: tempMessageId,
      error: error,
    );
  }

  factory ChatMessageTempModel.fromObject(Object? o) =>
      ChatMessageTempModel.fromJson(o as Map<String, dynamic>);

  factory ChatMessageTempModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageTempModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMessageTempModelToJson(this);
}

@JsonSerializable()
class ChatMessageFailedModel extends ChatMessageModel {
  final String error;
  final String tempMessageId;
  ChatMessageFailedModel({
    required super.id,
    required super.userId,
    required super.content,
    required super.createdAt,
    required this.tempMessageId,
    required this.error,
  });

  ChatMessageModel parseToChatModel() {
    return ChatMessageModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    );
  }

  ChatMessageModel parseToChatModelTemp() {
    return ChatMessageTempModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
      readUserIds: [],
      tempMessageId: tempMessageId,
    );
  }

  factory ChatMessageFailedModel.fromObject(Object? o) =>
      ChatMessageFailedModel.fromJson(o as Map<String, dynamic>);

  factory ChatMessageFailedModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFailedModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMessageFailedModelToJson(this);
}
