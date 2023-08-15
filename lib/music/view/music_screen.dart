import 'package:client/common/layout/default_pagination_nestedScrollView_layout.dart';
import 'package:client/music/provider/music_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/common/components/custom_sliver_app_bar.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/music/components/music_card.dart';
import 'package:client/music/model/music_model.dart';

// ignore: must_be_immutable
class MusicScreen extends ConsumerWidget {
  static String get routeName => 'music';

  ScrollController? scrollController;

  MusicScreen({super.key});

  Widget _renderAppBar(BuildContext context) {
    return const CustomSliverAppBar(
      title: "PlayList",
      backgroundImgPath: "asset/imgs/music/appbar_background.jpg",
      descriptionWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가끔 먹어야 맛있는',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '감자알칩',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                '같은',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderMusicList({
    required BuildContext context,
    required CursorPagination cp,
    required WidgetRef ref,
  }) {
    final musicList = cp.data as List<MusicModel>;
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
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
            padding: const EdgeInsets.only(
              top: 32.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                    spreadRadius: 4,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: MusicCard.fromModel(
                model: musicList[index],
              ),
            ),
          );
        },
        itemCount: musicList.length + 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultPaginationNestedScrollViewLayout(
      provider: musicProvider,
      body: (CursorPagination cp, ScrollController controller) {
        return _renderMusicList(
          cp: cp,
          ref: ref,
          context: context,
        );
      },
      sliverAppBar: _renderAppBar(context),
      onRefresh: () async {
        await ref.read(musicProvider.notifier).paginate(forceRefetch: true);
      },
    );
  }
}
