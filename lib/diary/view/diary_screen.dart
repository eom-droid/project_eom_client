import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:client/common/components/custom_sliver_app_bar.dart';
import 'package:client/common/components/pagination_list_view.dart';
import 'package:client/common/layout/defualt_sliver_appbar_listview_layout.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/diary/components/diary_card.dart';
import 'package:client/diary/provider/diary_provider.dart';
import 'package:client/diary/view/diary_detail_screen.dart';

import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class DiaryScreen extends ConsumerWidget {
  static String get routeName => 'diary';
  DiaryScreen({super.key});

  Map<String, VideoPlayerController>? vidControllers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultSliverAppbarListviewLayout(
      sliverAppBar: _renderAppBar(context),
      onRefresh: () async {
        await ref.read(diaryProvider.notifier).paginate(forceRefetch: true);
      },
      listview: PaginationListView(
        provider: diaryProvider,
        itemBuilder: <DiaryModel>(_, int index, model) {
          return Container();
        },
        customList: (CursorPagination cp) {
          return _renderDiaryList(
            cp: cp,
            ref: ref,
            context: context,
          );
        },
      ),
    );
  }

  Widget _renderAppBar(BuildContext context) {
    return const CustomSliverAppBar(
      title: "Diary",
      backgroundImgPath: "asset/imgs/diary/appbar_background.jpg",
      descriptionWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '옆에 한자리 남았어',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          Text(
            '뛰뛰빵빵',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderDiaryList({
    required CursorPagination cp,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    final diaryList = cp.data;
    if (vidControllers == null) {
      vidControllers = {};
      for (var element in diaryList) {
        if (DataUtils.isVidFile(element.thumbnail!)) {
          vidControllers![element.id] = VideoPlayerController.networkUrl(
            element.thumbnail!,
          );
        }
      }
    }

    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: cp.data.length + 1,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        itemBuilder: (context, index) {
          if (index == cp.data.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 64.0,
              ),
              child: Center(
                child: cp is CursorPaginationFetchingMore
                    ? const CircularProgressIndicator()
                    : const Text(
                        '마지막 입니다.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    // color: const Color(0xFFD9D9D9).withOpacity(0.3),
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 3.0,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                key: ValueKey(diaryList[index].id),
                onTap: () async {
                  context.pushNamed(
                    DiaryDetailScreen.routeName,
                    pathParameters: {'rid': diaryList[index].id},
                  );
                },
                child: DiaryCard.fromModel(
                  model: diaryList[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
