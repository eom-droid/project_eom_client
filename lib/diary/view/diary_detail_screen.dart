import 'package:client/common/components/custom_circle_avatar.dart';
import 'package:client/common/components/custom_text_field.dart';
import 'package:client/common/layout/default_scroll_base_pagination_layout.dart';
import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/common/utils/data_utils.dart';
import 'package:client/diary/components/diary_comment_card.dart';
import 'package:client/diary/model/diary_comment_model.dart';
import 'package:client/diary/provider/diary_comment_provider.dart';
import 'package:client/user/model/user_model.dart';
import 'package:client/user/provider/user_provider.dart';
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
  Map<String, VideoPlayerController> vidControllers = {};
  TextEditingController commentTextController = TextEditingController();
  bool commentLoading = false;
  ScrollController scrollController = ScrollController();

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
    final user = ref.watch(userProvider);

    if (state == null) {
      return const DefaultLayout(
        backgroundColor: BACKGROUND_BLACK,
        child: Center(
          child: CircularProgressIndicator(
            color: PRIMARY_COLOR,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BACKGROUND_BLACK,
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          controller: scrollController,
          slivers: [
            _renderThumbnail(model: state),
            _renderBasicInfo(model: state),

            // skeleton screen add here
            if (state is DiaryDetailModel) _renderContent(model: state),
            if (state is DiaryDetailModel)
              _renderLikeRowAfterContent(
                onTapLike: () {
                  if (user is UserModel) {
                    ref.read(diaryProvider.notifier).toggleLike(
                          diaryId: state.id,
                        );
                  }
                },
                user: user,
                model: state,
              ),

            if (state is DiaryDetailModel)
              _renderCommentCountAndInput(
                me: user,
                commentCount: state.commentCount,
                onTapAddComment: () async {
                  if (commentLoading) return;
                  // 1. commentLoading 활성화
                  setState(() {
                    commentLoading = true;
                  });
                  // 2. 댓글 생성
                  await ref
                      .read(diaryCommentProvider(state.id).notifier)
                      .createComment(
                        diaryId: state.id,
                        content: commentTextController.text,
                      );

                  // 3. toast 띄우기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("댓글이 추가되었습니다."),
                    ),
                  );

                  // 4. commentTextController 초기화
                  commentTextController.clear();
                  // 5. commentLoading 비활성화
                  setState(() {
                    commentLoading = false;
                  });
                },
                controller: commentTextController,
                commentLoading: commentLoading,
              ),
            if (state is DiaryDetailModel)
              _RenderComment(
                id: state.id,
                scrollController: scrollController,
                user: user,
              ),
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
          vidControllers[model.vids[vidIndex]] =
              VideoPlayerController.networkUrl(
            Uri.parse(model.vids[vidIndex]),
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

  SliverToBoxAdapter _renderLikeRowAfterContent({
    required VoidCallback onTapLike,
    required DiaryDetailModel model,
    required UserModelBase? user,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const Divider(
            color: BODY_TEXT_COLOR,
            thickness: 0.7,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: user is! UserModel ? null : onTapLike,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    top: 8.0,
                    right: 16.0,
                    left: 16.0,
                  ),
                  child: Icon(
                    user is! UserModel
                        ? Icons.heart_broken
                        : model.isLike
                            ? Icons.favorite
                            : Icons.favorite_border_outlined,
                    color: PRIMARY_COLOR,
                    size: 30.0,
                  ),
                ),
              ),
              Text(
                DataUtils.number2Unit.format(model.likeCount),
                style: const TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _renderCommentCountAndInput({
    required TextEditingController controller,
    required VoidCallback onTapAddComment,
    required bool commentLoading,
    required UserModelBase? me,
    required int commentCount,
  }) {
    print(me);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: [
          Row(
            children: [
              Text(
                "댓글 ${DataUtils.number2Unit.format(commentCount)}개",
                style: const TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
            ],
          ),
          const SizedBox(
            height: 16.0,
          ),
          if (me is! UserModel)
            const Text(
              "로그인 이후 작성이 가능합니다",
              style: TextStyle(
                color: BODY_TEXT_COLOR,
                fontSize: 14.5,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCircleAvatar(
                  url: me.profileImg,
                  size: 43,
                ),
                const SizedBox(
                  width: 18.0,
                ),
                Expanded(
                  child: SizedBox(
                    height: 32.0,
                    child: CustomTextField(
                      controller: controller,
                      hintText: "댓글 추가",
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                InkWell(
                  onTap: onTapAddComment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 12.0,
                    ),
                    child: commentLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: PRIMARY_COLOR,
                            ),
                          )
                        : const Text(
                            '댓글',
                            style: TextStyle(
                              color: PRIMARY_COLOR,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            )
        ]),
      ),
    );
  }
}

class _RenderComment extends ConsumerWidget {
  final String id;
  final ScrollController scrollController;
  final UserModelBase? user;
  const _RenderComment({
    required this.id,
    required this.scrollController,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: DefaultScrollBasePaginationLayout<DiaryCommentModel>(
        provider: diaryCommentProvider(id),
        controller: scrollController,
        body: (CursorPagination cp, ScrollController controller) {
          return _renderCommentList(
            scrollController: controller,
            cp: cp as CursorPagination<DiaryCommentModel>,
            onTapLike: (String commentId) {
              ref.read(diaryCommentProvider(id).notifier).toggleLike(
                    commentId: commentId,
                  );
            },
            onDeleteComment: (String commentId) async {
              await ref.read(diaryCommentProvider(id).notifier).deleteComment(
                    commentId: commentId,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("댓글이 삭제되었습니다."),
                ),
              );
            },
            onPatchComment: (String commentId, String content) async {
              await ref.read(diaryCommentProvider(id).notifier).patchComment(
                    commentId: commentId,
                    content: content,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("댓글이 수정되었습니다."),
                ),
              );
            },
            user: user,
          );
        },
        onRefresh: () async {
          await ref.read(diaryCommentProvider(id).notifier).paginate(
                forceRefetch: true,
              );
        },
        useDefaultListView: false,
      ),
    );
  }

  Widget _renderCommentList({
    required ScrollController scrollController,
    required CursorPagination<DiaryCommentModel> cp,
    required Function(String commentId) onTapLike,
    required Function(String commentId) onDeleteComment,
    required Function(String commentId, String content) onPatchComment,
    required UserModelBase? user,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 64,
        top: 32.0,
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 16.0,
          );
        },
        itemCount: cp.data.length,
        itemBuilder: (context, index) {
          final writer = cp.data[index].writer;
          return DiaryCommentCard.fromModel(
            userState: user,
            model: cp.data[index],
            diaryId: id,
            onLike: () {
              onTapLike(cp.data[index].id);
            },
            onDelete: () {
              onDeleteComment(cp.data[index].id);
            },
            onUpdate: (String content) {
              onPatchComment(cp.data[index].id, content);
            },
            isCommentMine: writer == null || user is! UserModel
                ? false
                : writer.id == user.id,
          );
        },
      ),
    );
  }
}
