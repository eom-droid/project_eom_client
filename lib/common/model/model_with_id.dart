abstract class IModelPagination {}

abstract class IModelWithId extends IModelPagination {
  final String id;
  IModelWithId({required this.id});
}

abstract class IModelWithPostDT extends IModelPagination {
  final DateTime postDT;

  IModelWithPostDT({required this.postDT});
}
