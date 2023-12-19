import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/model/pagination_params.dart';

// T는 paginating을 진행할 Model
// P는 pagination을 위한 params model
abstract class IBasePaginationRepository<T extends IModelPagination> {
  Future<CursorPagination<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
