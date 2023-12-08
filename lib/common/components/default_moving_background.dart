import 'package:client/common/const/data.dart';
import 'package:flutter/material.dart';

class DefaultMovingBackground extends StatelessWidget {
  final Widget child;
  const DefaultMovingBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundImage(),
          const _BackgroundFilter(),
          child,
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
  const _BackgroundFilter();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD9D9D9).withOpacity(0.1),
    );
  }
}
