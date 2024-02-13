import 'package:json_annotation/json_annotation.dart';

part 'chat_room_enter_model.g.dart';

@JsonSerializable()
class ChatRoomEnterModel {
  final String roomId;
  final String userId;

  ChatRoomEnterModel({
    required this.roomId,
    required this.userId,
  });

  factory ChatRoomEnterModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomEnterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomEnterModelToJson(this);
}
