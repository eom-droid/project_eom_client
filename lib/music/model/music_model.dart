import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/utils/data_utils.dart';

part 'music_model.g.dart';

@JsonSerializable()
class MusicModel implements IModelWithId {
  // id : 유일 아이디 값
  @override
  @JsonKey(name: '_id')
  final String id;
  // title : 노래 제목
  final String title;
  // artiste : 아티스트
  final String artiste;
  // review : 한줄평
  final String review;
  // albumCover : 앨범 커버
  @JsonKey(
    fromJson: DataUtils.pathToUrl,
  )
  final String albumCover;
  // youtubeMusicId : 유튜브 뮤직 ID
  final String youtubeMusicId;
  // spotifyId : Spotify ID
  final String spotifyId;

  MusicModel({
    required this.id,
    required this.title,
    required this.artiste,
    required this.review,
    required this.albumCover,
    required this.youtubeMusicId,
    required this.spotifyId,
  });

  factory MusicModel.empty() => MusicModel(
        id: '',
        title: '',
        artiste: '',
        review: '',
        albumCover: '',
        youtubeMusicId: '',
        spotifyId: '',
      );

  factory MusicModel.fromJson(Map<String, dynamic> json) =>
      _$MusicModelFromJson(json);

  Map<String, dynamic> toJson() => _$MusicModelToJson(this);
}
