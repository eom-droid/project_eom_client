import 'package:client/chat/model/model_with_from_json.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_socket_model.g.dart';

class WebSocketModelBase {
  final int status;

  WebSocketModelBase({
    required this.status,
  });
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class WebSocketModel<T> extends WebSocketModelBase {
  final List<T> data;

  WebSocketModel({
    required this.data,
    required int status,
  }) : super(status: status);

  factory WebSocketModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$WebSocketModelFromJson(json, fromJsonT);
}

class WebSocketModelError extends WebSocketModelBase {
  final String message;

  WebSocketModelError({
    required this.message,
    required int status,
  }) : super(status: status);
}

WebSocketModelBase? parseResponse<T extends IModelWithFromJson>(
  dynamic response,
  T Function(Object? json) fromJsonT,
) {
  try {
    // 1. dynamic -> Map<String, dynamic>
    final json = response as Map<String, dynamic>;
    // 2. Status Code에 따라서 분기
    if (json['status'] == null) {
      return WebSocketModelError(
        message: 'status가 없습니다.',
        status: 400,
      );
    }
    if (json['status'] >= 400) {
      return WebSocketModelError(
        message: json['message'],
        status: json['status'],
      );
    }
    // 3. data가 있는 경우
    if (json['data'] != null) {
      return WebSocketModel<T>.fromJson(
        json,
        fromJsonT,
      );
    }
  } catch (e) {
    print(e);
    return null;
  }
  return null;
}
