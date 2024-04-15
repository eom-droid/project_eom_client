enum SocketEvent {
  getChatRoom("getChatRoom"),
  getMessages("getMessages"),
  enterRoom("enterRoom"),
  leaveRoom("leaveRoom"),
  postMessage("postMessage"),
  connected("connected"),
  enterRoomOtherUser("enterRoomOtherUser"),
  newMessage("newMessage");

  final String value;
  const SocketEvent(this.value);

  // factory SocketEvent.getByCode(String value) {
  //   switch (value) {
  //     case "getChatRoom":
  //       return RoleType.user;
  //     case 5:
  //       return RoleType.manager;
  //     case 10:
  //       return RoleType.admin;
  //     default:
  //       return RoleType.user;
  //   }
  // }
}
