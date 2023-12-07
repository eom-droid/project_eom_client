import 'package:client/auth/model/token_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/utils/data_utils.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  // id : 유일 아이디 값
  @JsonKey(name: '_id')
  final String id;
  // title : 노래 제목
  final String? email;
  // review : 한줄평
  final String? nickName;
  // albumCover : 앨범 커버
  @JsonKey(
    fromJson: DataUtils.pathToUrlNullable,
  )
  final String? profileImg;
  // youtubeMusicId : 유튜브 뮤직 ID
  final String? snsId;
  // spotifyId : Spotify ID
  final String? provider;

  UserModel({
    required this.id,
    this.email,
    this.nickName,
    this.profileImg,
    this.snsId,
    this.provider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
