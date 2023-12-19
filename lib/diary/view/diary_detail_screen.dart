import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:client/common/components/custom_video_player.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/common/const/data.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/diary/model/diary_detail_model.dart';
import 'package:client/diary/model/diary_model.dart';
import 'package:client/diary/provider/diary_provider.dart';
import 'package:marquee/marquee.dart';
import 'package:video_player/video_player.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'diaryDetail';
  final String id;

  const DiaryDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  Map<String, VideoPlayerController> vidControllers = {};

  @override
  void initState() {
    super.initState();
    ref.read(diaryProvider.notifier).getDetail(id: widget.id);
  }

  @override
  void dispose() {
    vidControllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryDetailProvider(widget.id));

    if (state == null) {
      return const DefaultLayout(
        backgroundColor: BACKGROUND_BLACK,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BACKGROUND_BLACK,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _renderThumbnail(model: state),
            _renderBasicInfo(model: state),
            // skeleton screen add here
            if (state is DiaryDetailModel) _renderContent(model: state),
          ],
        ),
      ),
    );
  }

  SliverAppBar _renderThumbnail({
    required DiaryModel model,
  }) {
    final height =
        MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top;
    return SliverAppBar(
      backgroundColor: BACKGROUND_BLACK,
      // elevation: 0,
      expandedHeight: height,
      pinned: true,

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Hero(
              tag: 'thumbnail${model.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                child: Image.network(
                  model.thumbnail,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            Positioned(
              bottom: 32.0,
              right: 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  color: BODY_TEXT_COLOR,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: model.hashtags
                        .map<Padding>(
                          (e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: SizedBox(
                              child: Text(
                                '#$e',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width / 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black87,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _renderBasicInfo({
    required DiaryModel model,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 32.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat("yy년 M월 d일   HH시 mm분").format(model.createdAt),
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: BODY_TEXT_COLOR,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        model.weather,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: BODY_TEXT_COLOR,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32.0,
              ),
              SizedBox(
                height: 40.0,
                child: Marquee(
                  text: model.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                  blankSpace: 20.0,
                  scrollAxis: Axis.horizontal,
                  startAfter: const Duration(seconds: 1),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  pauseAfterRound: const Duration(seconds: 1),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPadding _renderContent({
    required DiaryDetailModel model,
  }) {
    int txtIndex = 0;
    int imgIndex = 0;
    int vidIndex = 0;

    List<String?> content = <String>[];
    try {
      content = model.contentOrder.map((e) {
        if (e == DiaryContentType.txt) {
          return model.txts[txtIndex++];
        } else if (e == DiaryContentType.img) {
          return model.imgs[imgIndex++];
        } else if (e == DiaryContentType.vid) {
          vidControllers[model.vids[vidIndex]] = VideoPlayerController.network(
            model.vids[vidIndex],
          );

          return model.vids[vidIndex++];
        }
        return null;
      }).toList();
    } catch (e) {
      return const SliverPadding(padding: EdgeInsets.all(0.0));
    }

    if (model.contentOrder.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.all(0.0));
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
      sliver: SliverList.separated(
        itemCount: content.length,
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 32.0,
          );
        },
        itemBuilder: (context, index) {
          final contentType = model.contentOrder[index];

          if (contentType == DiaryContentType.txt) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                content[index]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: INPUT_BORDER_COLOR,
                  height: 1.7,
                ),
              ),
            );
          } else if (contentType == DiaryContentType.img) {
            return ClipRRect(
              child: Image.network(
                content[index]!,
                fit: BoxFit.cover,
              ),
            );
          } else if (contentType == DiaryContentType.vid) {
            return CustomVideoPlayer(
              videoController: vidControllers[content[index]!]!,
              displayBottomSlider: false,
            );
          }
          return null;
        },
      ),
    );
  }
}
