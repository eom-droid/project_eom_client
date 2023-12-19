abstract class IModelPagination {}

abstract class IModelWithId extends IModelPagination {
  final String id;
  IModelWithId({required this.id});
}
