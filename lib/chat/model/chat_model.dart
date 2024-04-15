import 'package:client/chat/model/chat_member.dart';
import 'package:client/chat/model/chat_message_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/model_with_id.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel implements IModelWithId {
  // id : 유일 아이디 값
  @override
  @JsonKey(name: '_id')
  final String id;
  // title : 제목
  final String title;
  // members : 채팅방 멤버
  final List<ChatMember> members;
  // max : 최대 인원
  final int max;
  // lastMessage : 마지막 채팅
  final ChatMessageModel? lastMessage;

  ChatModel({
    required this.id,
    required this.title,
    required this.members,
    required this.max,
    required this.lastMessage,
  });

  ChatModel copyWith({
    String? id,
    String? title,
    List<ChatMember>? members,
    int? max,
    ChatMessageModel? lastMessage,
  }) {
    return ChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      members: members ?? this.members,
      max: max ?? this.max,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  ChatDetailModel toDetailModel({
    bool hasMoreMessage = false,
    List<ChatMessageModel> messages = const [],
  }) {
    return ChatDetailModel(
      id: id,
      title: title,
      members: members,
      max: max,
      lastMessage: lastMessage,
      hasMoreMessage: hasMoreMessage,
      messages: messages,
    );
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

@JsonSerializable()
class ChatDetailModel extends ChatModel {
  // hasMoreMessage : 더 많은 메시지가 있는지 여부
  // 원래는 cursorPagination으로 진행해야되지만 CusorPagination이라는 객체를 fromJosn으로 직렬화가 불가능함

  @JsonKey(
    defaultValue: true,
  )
  final bool hasMoreMessage;
  // message : 채팅방 메시지
  @JsonKey(
    defaultValue: [],
  )
  final List<ChatMessageModel> messages;

  ChatDetailModel({
    required super.id,
    required super.title,
    required super.members,
    required super.max,
    required super.lastMessage,
    this.hasMoreMessage = false,
    required this.messages,
  });

  @override
  ChatDetailModel copyWith({
    String? id,
    String? title,
    List<ChatMember>? members,
    int? max,
    ChatMessageModel? lastMessage,
    bool? hasMoreMessage,
    List<ChatMessageModel>? messages,
  }) {
    return ChatDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      members: members ?? this.members,
      max: max ?? this.max,
      lastMessage: lastMessage ?? this.lastMessage,
      hasMoreMessage: hasMoreMessage ?? this.hasMoreMessage,
      messages: messages ?? this.messages,
    );
  }

  factory ChatDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ChatDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatDetailModelToJson(this);
}
