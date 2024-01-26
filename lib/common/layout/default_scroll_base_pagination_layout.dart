import 'package:client/common/components/cursor_pagination_error_comp.dart';
import 'package:client/common/components/cursor_pagination_loading_comp.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/common/utils/pagination_utils.dart';

class DefaultScrollBasePaginationLayout<T extends IModelWithId>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationNotifier, CursorPaginationBase>
      provider;
  final Widget Function(CursorPagination<T> cp, ScrollController controller)
      body;
  final ScrollController? controller;
  final Widget? sliverAppBar;
  final Future<void> Function() onRefresh;
  final bool useDefaultListView;

  const DefaultScrollBasePaginationLayout({
    Key? key,
    required this.provider,
    required this.body,
    this.sliverAppBar,
    required this.onRefresh,
    this.controller,
    this.useDefaultListView = true,
  }) : super(key: key);

  @override
  ConsumerState<DefaultScrollBasePaginationLayout> createState() =>
      _DefaultScrollBasePaginationLayoutState<T>();
}

class _DefaultScrollBasePaginationLayoutState<T extends IModelWithId>
    extends ConsumerState<DefaultScrollBasePaginationLayout> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScrollController();
    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(widget.provider.notifier),
    );
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();

    super.dispose();
  }

  Widget loadBody(CursorPaginationBase state, ScrollController controller) {
    // 초기 로딩
    if (state is CursorPaginationLoading) {
      return const CursorPaginationLoadingComp();
    }

    // 에러 발생 시
    if (state is CursorPaginationError) {
      return CursorPaginationErrorComp(
        state: state,
        onRetry: () {
          ref.read(widget.provider.notifier).paginate(
                forceRefetch: true,
              );
        },
      );
    }

    // CursorPagination
    // CursorPaginationFetchMore
    // CursorPaginationRefetching

    final cp = state as CursorPagination<T>;
    return widget.body(cp, controller);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    if (!widget.useDefaultListView) {
      return loadBody(state, controller);
    } else {
      return Scaffold(
        backgroundColor: BACKGROUND_BLACK,
        body: RefreshIndicator(
          strokeWidth: 3.0,
          backgroundColor: BACKGROUND_BLACK,
          color: Colors.white,
          onRefresh: widget.onRefresh,
          edgeOffset: MediaQuery.of(context).size.width + 100,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: controller,
            slivers: [
              if (widget.sliverAppBar != null) widget.sliverAppBar!,
              SliverToBoxAdapter(
                child: loadBody(state, controller),
              ),
            ],
          ),
        ),
      );
    }
  }
}
