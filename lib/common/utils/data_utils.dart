import 'package:client/common/const/data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataUtils {
  static String pathToUrl(String value) {
    String defaultAWSS3Url = dotenv.env['DefaultAWSS3Url']!;
    return defaultAWSS3Url + value;
  }

  static String? pathToUrlNullable(String? value) {
    if (value != null) {
      String defaultAWSS3Url = dotenv.env['DefaultAWSS3Url']!;
      return defaultAWSS3Url + value;
    } else {
      return null;
    }
  }

  static List<String> listPathsToUrls(List paths) {
    return paths.map((e) => pathToUrl(e)).toList();
  }

  static DateTime stringToDateTime(String value) {
    return DateTime.parse(value);
  }

  static DateTime toLocalTimeZone(String value) {
    return stringToDateTime(value).toLocal();
  }

  static List<DiaryContentType> listStringToListDiaryContentType(
      List<dynamic> value) {
    return value.map((e) => DiaryContentType.getByCode(e)).toList();
  }

  static List<String> listDiaryContentTypeToListString(
      List<DiaryContentType> value) {
    return value.map((e) => e.value).toList();
  }

  static DiaryCategory stringToDiaryCategory(String value) {
    return DiaryCategory.getByCode(value);
  }

  static String diaryCategoryToString(DiaryCategory value) {
    return value.value;
  }

  static bool isImgFile(String filePath) {
    final imageFileExtension = [
      "jpg",
      "jpeg",
      "png",
      "gif",
      "bmp",
      "JPG",
      "JPEG",
      "PNG",
      "GIF",
      "BMP",
    ];

    final fileExtension = filePath.split('.').last;
    return imageFileExtension.contains(fileExtension);
  }

  static bool isVidFile(String filePath) {
    final videoFileExtension = [
      "mp4",
      "MP4",
      "avi",
      "AVI",
      "wmv",
      "WMV",
      "mov",
      "MOV",
    ];

    final fileExtension = filePath.split('.').last;
    return videoFileExtension.contains(fileExtension);
  }
}
