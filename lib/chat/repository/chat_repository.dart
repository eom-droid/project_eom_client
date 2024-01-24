import 'package:client/chat/model/chat_model.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/pagination_params.dart';
import 'package:client/common/repository/base_pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider =
    Provider.family<ChatRepository, String>((ref, roomId) {
  return ChatRepository();
});

class ChatRepository implements IBasePaginationRepository<ChatModel> {
  ChatRepository();

  @override
  Future<CursorPagination<ChatModel>> paginate(
      {PaginationParams? paginationParams}) {
    return Future.value(CursorPagination<ChatModel>(
      meta: CursorPaginationMeta(
        hasMore: true,
        count: 0,
      ),
      data: [],
    ));
    // paginate작업 진행
  }

  Future<ChatModel> createChat() {
    return Future.value(ChatModel(
      id: '1',
      content: "test",
      createdAt: DateTime.now(),
      userId: '1',
    ));
  }
}
