import 'package:client/common/const/colors.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/common/utils/pagination_utils.dart';

class DefaultPaginationNestedScrollViewLayout<T extends IModelWithId>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationNotifier, CursorPaginationBase>
      provider;
  final Widget Function(CursorPagination<T> cp, ScrollController controller)
      body;
  final ScrollController? controller;
  final Widget sliverAppBar;
  final Future<void> Function() onRefresh;
  const DefaultPaginationNestedScrollViewLayout({
    Key? key,
    required this.provider,
    required this.body,
    required this.sliverAppBar,
    required this.onRefresh,
    this.controller,
  }) : super(key: key);

  @override
  ConsumerState<DefaultPaginationNestedScrollViewLayout> createState() =>
      _DefaultPaginationNestedScrollViewLayoutState<T>();
}

class _DefaultPaginationNestedScrollViewLayoutState<T extends IModelWithId>
    extends ConsumerState<DefaultPaginationNestedScrollViewLayout> {
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

  Widget whenLoading() {
    return const SizedBox(
      height: 100.0,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget whenError(CursorPaginationError state) {
    return SizedBox(
      height: 300.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0, color: Colors.white)),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                ref.read(widget.provider.notifier).paginate(
                      forceRefetch: true,
                    );
              },
              child: const Text('다시시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadBody(CursorPaginationBase state, ScrollController controller) {
    // 초기 로딩
    if (state is CursorPaginationLoading) {
      return whenLoading();
    }

    // 에러 발생 시
    if (state is CursorPaginationError) {
      return whenError(state);
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

    // 이거는 refreshIndicator가 동작하지 않음
    // 현재로서는 RefreshIndicator을 parent에 위치하고
    // edgeOffset을 이용해서 중앙에 배치하는 방식으로 진행함
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
            widget.sliverAppBar,
            SliverToBoxAdapter(
              child: loadBody(state, controller),
            ),
          ],
        ),
      ),
    );
  }
}
