import 'package:client/chat/const/chat_default.dart';

class ChatResponseModel {
  final SocketEvent event;
  final dynamic data;
  ChatResponseModel({
    required this.event,
    required this.data,
  });
}
