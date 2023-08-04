import 'package:flutter/material.dart';
import 'package:client/common/const/colors.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final bool displayBottomSlider;

  const CustomVideoPlayer({
    required this.videoController,
    this.displayBottomSlider = true,
    Key? key,
  }) : super(key: key);

  @override
  CustomVideoPlayerState createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {
  Duration currentPosition = const Duration();

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void dispose() {
    widget.videoController.removeListener(updateSlider);
    super.dispose();
  }

  initializeController() {
    updateSlider();
    if (!widget.videoController.value.isInitialized) {
      widget.videoController.initialize().then((value) => setState(() {}));
    }

    widget.videoController.addListener(updateSlider);
  }

  updateSlider() {
    final currentPosition = widget.videoController.value.position;
    setState(() {
      this.currentPosition = currentPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.videoController.value.isInitialized) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: const Center(
          child: LinearProgressIndicator(
            color: PRIMARY_COLOR,
            backgroundColor: INPUT_BG_COLOR,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: widget.videoController.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(
            widget.videoController,
          ),
          _Controls(
            onTap: onPlayPressed,
            isPlaying: widget.videoController.value.isPlaying,
          ),
          if (widget.displayBottomSlider)
            _SliderBottom(
              currentPosition: currentPosition,
              maxPosition: widget.videoController.value.duration,
              onSliderChanged: onSliderChanged,
            ),
        ],
      ),
    );
  }

  void onSliderChanged(double val) {
    widget.videoController.seekTo(
      Duration(
        seconds: val.toInt(),
      ),
    );
  }

  void onPlayPressed() {
    // 이미 실행중이면 중지
    // 실행중이 아니면 실행
    setState(() {
      if (widget.videoController.value.isPlaying) {
        widget.videoController.pause();
      } else {
        widget.videoController.play();
      }
    });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onTap;
  final bool isPlaying;

  const _Controls({
    required this.onTap,
    required this.isPlaying,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isPlaying ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Icon(
            isPlaying ? null : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom({
    required this.currentPosition,
    required this.maxPosition,
    required this.onSliderChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Slider(
                value: currentPosition.inSeconds.toDouble(),
                onChanged: onSliderChanged,
                max: maxPosition.inSeconds.toDouble(),
                min: 0,
                activeColor: PRIMARY_COLOR,
              ),
            ),
            Text(
              '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
