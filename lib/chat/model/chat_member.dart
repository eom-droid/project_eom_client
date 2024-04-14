import 'package:client/common/utils/data_utils.dart';
import 'package:json_annotation/json_annotation.dart';
part 'chat_member.g.dart';

@JsonSerializable()
class ChatMember {
  // id : 유일 아이디 값
  @JsonKey(name: '_id')
  final String id;
  // profileImg : 프로필 이미지
  @JsonKey(
    fromJson: DataUtils.pathToUrlNullable,
  )
  final String? profileImg;
  // nickname : 닉네임
  final String nickname;
  // lastReadChatId : 마지막으로 읽은 채팅 아이디
  final String? lastReadChatId;

  ChatMember({
    required this.id,
    this.profileImg,
    required this.nickname,
    this.lastReadChatId,
  });

  ChatMember copyWith({
    String? id,
    String? profileImg,
    String? nickname,
    String? lastReadChatId,
  }) {
    return ChatMember(
      id: id ?? this.id,
      profileImg: profileImg ?? this.profileImg,
      nickname: nickname ?? this.nickname,
      lastReadChatId: lastReadChatId ?? this.lastReadChatId,
    );
  }

  factory ChatMember.fromJson(Map<String, dynamic> json) =>
      _$ChatMemberFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMemberToJson(this);
}
