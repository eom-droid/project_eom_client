import 'package:client/chat/model/chat_model.dart';
import 'package:client/user/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/utils/data_utils.dart';

part 'chat_room_model.g.dart';

@JsonSerializable()
class ChatRoomModel implements IModelWithId {
  // id : 유일 아이디 값
  @override
  @JsonKey(name: '_id')
  final String id;
  // title : 제목
  final String title;
  // members : 채팅방 멤버
  final List<UserModel> members;
  // max : 최대 인원
  final int max;
  // lastChat : 마지막 메시지
  final ChatModel? lastChat;

  ChatRoomModel({
    required this.id,
    required this.title,
    required this.members,
    required this.max,
    required this.lastChat,
  });

  factory ChatRoomModel.fromObject(Object? o) =>
      ChatRoomModel.fromJson(o as Map<String, dynamic>);

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomModelToJson(this);
}
