import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/model/model_with_id.dart';
import 'package:client/common/provider/pagination_provider.dart';
import 'package:client/common/utils/pagination_utils.dart';

typedef PaginationWidgetBuilder<T extends IModelPagination> = Widget Function(
  BuildContext context,
  int index,
  T model,
);

class PaginationListView<T extends IModelPagination>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationProvider, CursorPaginationBase>
      provider;
  final PaginationWidgetBuilder<T> itemBuilder;
  final Widget Function(CursorPagination<T> cp)? customList;
  final ScrollController? controller;
  const PaginationListView({
    Key? key,
    required this.provider,
    required this.itemBuilder,
    this.customList,
    this.controller,
  }) : super(key: key);

  @override
  ConsumerState<PaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends IModelPagination>
    extends ConsumerState<PaginationListView> {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    // 초기 로딩 시
    if (state is CursorPaginationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 발생 시
    if (state is CursorPaginationError) {
      return Padding(
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
      );
    }

    // CursorPagination
    // CursorPaginationFetchMore
    // CursorPaginationRefetching

    final cp = state as CursorPagination<T>;

    if (widget.customList != null) {
      return widget.customList!(cp);
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: BACKGROUND_BLACK,
      onRefresh: () async {
        ref.read(widget.provider.notifier).paginate(forceRefetch: true);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        // +1을 해주는 이유 : 마지막에 로딩 중 위젯을 띄워주기 위함
        itemCount: cp.data.length + 1,
        itemBuilder: (context, index) {
          if (index == cp.data.length) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: cp is CursorPaginationFetchingMore
                    ? const CircularProgressIndicator()
                    : const Text('마지막 입니다.'),
              ),
            );
          }
          final pItem = cp.data[index];

          return widget.itemBuilder(
            context,
            index,
            pItem,
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 16.0,
          );
        },
      ),
    );
  }
}
