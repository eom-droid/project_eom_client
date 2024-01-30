enum ChatResponseState {
  getChatRoomsRes,
  getMessageRes,
  paginateMessageRes,
  joinRoomRes,
  postMessageRes,
}

class ChatResponseModel {
  final ChatResponseState state;
  final dynamic data;
  ChatResponseModel({
    required this.state,
    required this.data,
  });
}
