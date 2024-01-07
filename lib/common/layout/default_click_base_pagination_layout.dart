import 'package:client/common/model/model_with_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/provider/pagination_provider.dart';

class DefaultClickBasePaginationLayout<T extends IModelWithId>
    extends ConsumerWidget {
  final StateNotifierProvider<PaginationNotifier, CursorPaginationBase>
      provider;
  final Widget Function(CursorPagination<T> cp) body;

  const DefaultClickBasePaginationLayout({
    super.key,
    required this.provider,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    if (state is CursorPaginationLoading) {
      return whenLoading();
    }

    // 에러 발생 시
    if (state is CursorPaginationError) {
      return whenError(state, ref);
    }

    // CursorPagination
    // CursorPaginationFetchMore
    // CursorPaginationRefetching

    final cp = state as CursorPagination<T>;
    return body(
      cp,
    );
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

  Widget whenError(CursorPaginationError state, WidgetRef ref) {
    return SizedBox(
      height: 300.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                ref.read(provider.notifier).paginate(
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
}
