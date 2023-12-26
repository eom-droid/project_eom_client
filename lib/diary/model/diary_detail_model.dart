import 'package:client/diary/model/diary_comment_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/diary/model/diary_model.dart';

part 'diary_detail_model.g.dart';

@JsonSerializable()
class DiaryDetailModel extends DiaryModel {
  // txts : 텍스트 리스트
  final List<String> txts;

  // imgs : 이미지 리스트
  @JsonKey(fromJson: DataUtils.listPathsToUrls)
  final List<String> imgs;

  // vids : 비디오 리스트 -> 초기에는 직접 로딩하지 않고
  @JsonKey(fromJson: DataUtils.listPathsToUrls)
  final List<String> vids;
  // contentOrder : 컨텐츠 순서
  // 추후 markdown 형식으로 저장할 예정
  // 현재는 위 3가지 txt,img,vid의 표출 순서를 정의
  @JsonKey(
    fromJson: DataUtils.listStringToListDiaryContentType,
    toJson: DataUtils.listDiaryContentTypeToListString,
  )
  final List<DiaryContentType> contentOrder;

  final List<DiaryCommentModel>? comments;

  DiaryDetailModel({
    required super.id,
    required super.title,
    required super.writer,
    required super.weather,
    required super.hashtags,
    required super.thumbnail,
    required super.category,
    required super.isShown,
    required this.txts,
    required this.imgs,
    required this.vids,
    required this.contentOrder,
    required super.createdAt,
    required super.likeCount,
    required super.isLike,
    this.comments,
  });

  @override
  DiaryDetailModel copyWith({
    String? id,
    String? title,
    String? writer,
    String? weather,
    List<String>? hashtags,
    String? thumbnail,
    DiaryCategory? category,
    bool? isShown,
    DateTime? createdAt,
    List<String>? txts,
    List<String>? imgs,
    List<String>? vids,
    List<DiaryContentType>? contentOrder,
    int? likeCount,
    bool? isLike,
    List<DiaryCommentModel>? comments,
  }) {
    return DiaryDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      writer: writer ?? this.writer,
      weather: weather ?? this.weather,
      hashtags: hashtags ?? this.hashtags,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      isShown: isShown ?? this.isShown,
      txts: txts ?? this.txts,
      imgs: imgs ?? this.imgs,
      vids: vids ?? this.vids,
      contentOrder: contentOrder ?? this.contentOrder,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLike: isLike ?? this.isLike,
      comments: comments ?? this.comments,
    );
  }

  factory DiaryDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DiaryDetailModelToJson(this);
}
