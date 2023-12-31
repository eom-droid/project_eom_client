import 'package:client/common/const/data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

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

  static RoleType numberToRoleType(int value) {
    return RoleType.getByCode(value);
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

  static bool isEmailValid(String email) {
    final emailRegExp = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailRegExp;
  }

  static NumberFormat number2Unit = NumberFormat.compact(locale: "en_US");

  // 현재시각과의 차이가
  // 1분 이내 : 방금 전
  // 1시간 이내 : n분 전
  // 1일 이내 : n시간 전
  // 1주 이내 : n일 전
  // 1달 이내 : n주 전
  // 1년 이내 : n달 전
  // 1년 이상 : n년 전
  // DateTime을 매게변수로 받음

  static String timeAgoSinceDate(DateTime date) {
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if (difference.inMinutes < 0) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}달 전';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
  }
}
