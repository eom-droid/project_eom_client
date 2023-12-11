import 'package:client/common/const/colors.dart';
import 'package:client/common/const/data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultMovingBackground extends StatelessWidget {
  final List<Widget> children;
  final double opacity;
  final Color filterColor;
  final bool? showAppBar;
  const DefaultMovingBackground({
    super.key,
    required this.children,
    this.filterColor = const Color(0xFFD9D9D9),
    this.opacity = 0.1,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: showAppBar!
            ? renderAppBar(
                close: () {
                  context.pop();
                },
              )
            : null,
        body: Stack(
          children: [
            const _BackgroundImage(),
            _BackgroundFilter(
              opacity: opacity,
              filterColor: filterColor,
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  renderAppBar({
    required VoidCallback close,
  }) {
    return AppBar(
      toolbarHeight: 50.0,
      titleSpacing: 0,
      backgroundColor: const Color(0x44000000),
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: Colors.white,
          height: 1.0,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  "asset/imgs/logo/logo.png",
                  width: 35,
                  height: 35,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Eom Tae Ho',
                  style: TextStyle(
                    fontSize: 20,
                    color: INPUT_BG_COLOR,
                    fontFamily: "sabreshark",
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: close,
            child: const Icon(
              Icons.close_sharp,
              color: INPUT_BG_COLOR,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatefulWidget {
  const _BackgroundImage();

  @override
  State<_BackgroundImage> createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<_BackgroundImage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 120),
    vsync: this,
    value: 0.0,
    lowerBound: 0.0,
    upperBound:
        (homeBackgroundImageWidth * MediaQuery.of(context).size.height) -
            (MediaQuery.of(context).size.width),
  )..repeat(reverse: true);

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: ((context, child) {
        return Positioned(
          left: -_animationController.value,
          child: child!,
        );
      }),
      child: Image.asset(
        "asset/imgs/home_background.png",
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _BackgroundFilter extends StatelessWidget {
  final double opacity;
  final Color filterColor;
  const _BackgroundFilter({
    required this.opacity,
    required this.filterColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: filterColor.withOpacity(opacity),
      // color: const Color(0xFFD9D9D9).withOpacity(opacity),
    );
  }
}
