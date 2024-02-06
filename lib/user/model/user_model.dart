import 'package:client/common/const/data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/utils/data_utils.dart';

part 'user_model.g.dart';

abstract class UserModelBase {}

class UserModelError extends UserModelBase {
  final String message;

  UserModelError({
    required this.message,
  });
}

class UserModelLoading extends UserModelBase {}

@JsonSerializable()
class UserModel extends UserModelBase {
  // id : 유일 아이디 값
  @JsonKey(name: '_id')
  final String id;
  // email : 이메일
  final String? email;
  // nickname : 닉네임
  final String nickname;
  // profileImg : 프로필 이미지
  @JsonKey(
    fromJson: DataUtils.pathToUrlNullable,
  )
  final String? profileImg;
  // snsId : sns 아이디
  final String? snsId;
  // provider : 제공자
  final String? provider;
  // role : 권한
  @JsonKey(
    defaultValue: RoleType.user,
    fromJson: DataUtils.numberToRoleType,
  )
  final RoleType? role;

  UserModel({
    required this.id,
    this.email,
    required this.nickname,
    this.profileImg,
    this.snsId,
    this.provider,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
