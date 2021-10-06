import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fl_video_player/src/widgets/full_screen_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'package:fl_video_player/src/widgets/fl_video_progress_bar.dart';

import 'fl_enums.dart';
import 'fl_video_controller.dart';
import 'widgets/material_icon_button.dart';

class FlVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final String? vimeoVideoId;
  final bool autoPlay;
  final bool isLooping;
  const FlVideoPlayer({
    Key? key,
    this.videoUrl,
    this.vimeoVideoId,
    this.autoPlay = true,
    this.isLooping = false,
  }) : super(key: key);

  @override
  _FlVideoPlayerState createState() => _FlVideoPlayerState();
}

class _FlVideoPlayerState extends State<FlVideoPlayer>
    with SingleTickerProviderStateMixin {
  late FlVideoController _flCtr;

  @override
  void initState() {
    super.initState();
    _flCtr = Get.put(FlVideoController())
      ..videoInit(
              videoUrl: widget.videoUrl,
              vimeoVideoId: widget.vimeoVideoId,
              isLooping: widget.isLooping)
          .then((value) {
        _flCtr
          ..playPauseCtr = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 450),
          )
          ..autoPlay = widget.autoPlay
          ..checkAutoPlayVideo();
      });
    _flCtr.addListenerId('flVideoState', _flCtr.flStateListner);
  }

  @override
  void dispose() {
    _flCtr.videoCtr?.removeListener(_flCtr.videoListner);
    _flCtr.removeListenerId('flVideoState', _flCtr.flStateListner);
    _flCtr.videoCtr?.dispose();
    _flCtr.playPauseCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///
    const circularProgressIndicator = CircularProgressIndicator(
      backgroundColor: Colors.black87,
      color: Colors.white,
      strokeWidth: 2,
    );
    return GetBuilder<FlVideoController>(
      builder: (_) => Center(
        child: ColoredBox(
          color: Colors.black,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: _flCtr.videoCtr == null
                    ? circularProgressIndicator
                    : _flCtr.videoCtr!.value.isInitialized
                        ? const Hero(tag: 'flVideo-play', child: FlPlayer())
                        : circularProgressIndicator,
              )),
        ),
      ),
    );
  }
}

class FlPlayer extends StatelessWidget {
  const FlPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlVideoController>();
    return GetBuilder<FlVideoController>(
      builder: (_) => Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(_flCtr.videoCtr!),
          GetBuilder<FlVideoController>(
            id: 'overlay',
            builder: (_flCtr) => AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _flCtr.overlayVisible ? 1 : 0,
              child: Stack(
                children: [
                  MobileOverlay(),

                  // if (kIsWeb)
                  //   Align(
                  //     alignment: Alignment.bottomCenter,
                  //     child: FlVideoProgressBar(
                  //       _flCtr.videoCtr!,
                  //       allowScrubbing: true,
                  //       padding: EdgeInsets.all(20),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
          GetBuilder<FlVideoController>(
            id: 'flVideoState',
            builder: (_flCtr) => _flCtr.flVideoState == FlVideoState.loading
                ? const Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    strokeWidth: 2,
                  ))
                : const SizedBox(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: FlVideoProgressBar(
              allowGestures: true,
              height: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class MobileOverlay extends StatelessWidget {
  const MobileOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final _flCtr = Get.find<FlVideoController>();
    const durationTextStyle = TextStyle(color: Colors.white70);
    log('ss');
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: VideoOverlayDetector(
                onDoubleTap: _flCtr.onLeftDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: const _LeftRightDoubleTapBox(
                    isLeft: true,
                  ),
                ),
              ),
            ),
            VideoOverlayDetector(
              child: ColoredBox(
                color: overlayColor,
                child: const _PlayPause(),
              ),
            ),
            Expanded(
              child: VideoOverlayDetector(
                onDoubleTap: _flCtr.onRightDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: const _LeftRightDoubleTapBox(
                    isLeft: false,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialIconButton(
                    color: itemColor,
                    onHover: !kIsWeb
                        ? (_) {
                            _flCtr.isShowOverlay(true);
                          }
                        : (_) {},
                    onPressed: _flCtr.overlayVisible
                        ? () => _bottomSheet(context)
                        : _flCtr.toggleVideoOverlay,
                    child: const Icon(
                      Icons.more_vert_rounded,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GetBuilder<FlVideoController>(
                      id: 'video-progress',
                      builder: (_flCtr) {
                        return Text(
                            _flCtr.calculateVideoDuration(_flCtr.videoPosition),
                            style: const TextStyle(color: itemColor));
                      }),
                  const Text(
                    ' / ',
                    style: durationTextStyle,
                  ),
                  Text(
                    _flCtr.calculateVideoDuration(_flCtr.videoDuration),
                    style: durationTextStyle,
                  ),
                  const Spacer(),
                  MaterialIconButton(
                    color: itemColor,
                    onHover:
                        !kIsWeb ? (_) => _flCtr.isShowOverlay(true) : (_) {},
                    onPressed: _flCtr.overlayVisible
                        ? () => _flCtr.isFullScreen
                            ? _exitFullScreen(context)
                            : _fullScreen(context)
                        : _flCtr.toggleVideoOverlay,
                    child: Icon(
                      _flCtr.isFullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _exitFullScreen(BuildContext context) {
    Get.find<FlVideoController>().disableFullScreen().then((value) {
      Navigator.of(context).pop();
    });
  }

  void _fullScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque:true,
        fullscreenDialog: true,
        pageBuilder: (BuildContext context, _, __) => const FullScreenView(),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _MobileBottomSheet(),
    );
  }
}

class _MobileBottomSheet extends StatelessWidget {
  const _MobileBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlVideoController>(
      builder: (_flCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_flCtr.videoPlayerType == FlVideoPlayerType.vimeo)
            _bottomSheetTiles(
              title: 'Quality',
              icon: Icons.video_settings_rounded,
              subText: '${_flCtr.vimeoPlayingVideoQuality}p',
              onTap: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => const _VideoQualitySelector());
                });
                // await Future.delayed(
                //   const Duration(milliseconds: 100),
                // );
              },
            ),
          _bottomSheetTiles(
            title: 'Loop video',
            icon: Icons.loop_rounded,
            subText: _flCtr.isLooping ? 'On' : 'Off',
            onTap: () {
              Navigator.of(context).pop();
              _flCtr.toggleLooping();
            },
          ),
          _bottomSheetTiles(
              title: 'Playback speed',
              icon: Icons.slow_motion_video_rounded,
              subText: _flCtr.currentPaybackSpeed,
              onTap: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const _VideoPlaybackSelector());
                });
              }),
        ],
      ),
    );
  }

  ListTile _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              title,
            ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              const SizedBox(
                height: 4,
                width: 4,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                )),
              ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoQualitySelector extends StatelessWidget {
  const _VideoQualitySelector({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flctr = Get.find<FlVideoController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _flctr.vimeoVideoUrls
              ?.map((e) => ListTile(
                    title: Text('${e.quality}p'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _flctr.changeVideoQuality(e.quality);
                    },
                  ))
              .toList() ??
          [],
    );
  }
}

class _VideoPlaybackSelector extends StatelessWidget {
  const _VideoPlaybackSelector({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flctr = Get.find<FlVideoController>();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _flctr.videoPlaybackSpeeds
            .map((e) => ListTile(
                  title: Text(e),
                  onTap: () {
                    Navigator.of(context).pop();
                    _flctr.setVideoPlayBack(e);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _LeftRightDoubleTapBox extends StatelessWidget {
  final bool isLeft;
  const _LeftRightDoubleTapBox({
    Key? key,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlVideoController>(
      id: 'double-tap',
      builder: (_flctr) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _flctr.isLeftDbTapIconVisible && isLeft
                ? 1
                : _flctr.isRightDbTapIconVisible && !isLeft
                    ? 1
                    : 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(isLeft
                      ? 'packages/fl_video_player/assets/forward_left.json'
                      : 'packages/fl_video_player/assets/forward_right.json'),
                  if (isLeft
                      ? _flctr.isLeftDbTapIconVisible
                      : _flctr.isRightDbTapIconVisible)
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: Text(
                        '${_flctr.isLeftDbTapIconVisible ? _flctr.leftDoubleTapduration : _flctr.rightDubleTapduration} seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoOverlayDetector extends StatefulWidget {
  final Widget? child;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  const VideoOverlayDetector({
    Key? key,
    this.child,
    this.onDoubleTap,
    this.onTap,
  }) : super(key: key);

  @override
  State<VideoOverlayDetector> createState() => _VideoOverlayDetectorState();
}

class _VideoOverlayDetectorState extends State<VideoOverlayDetector> {
  final _flCtr = Get.find<FlVideoController>();

  @override
  void dispose() {
    _flCtr.hoverOverlayTimer?.cancel();
    _flCtr.leftDoubleTapTimer?.cancel();
    _flCtr.rightDoubleTapTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: (event) => _flCtr.onOverlayHover(),
        onExit: (event) => _flCtr.onOverlayHoverExit(),
        child: GestureDetector(
            onTap: widget.onTap ?? _flCtr.toggleVideoOverlay,
            onDoubleTap: widget.onDoubleTap,
            child: widget.child));
  }
}

class _PlayPause extends StatefulWidget {
  const _PlayPause({
    Key? key,
  }) : super(key: key);

  @override
  State<_PlayPause> createState() => _PlayPauseState();
}

class _PlayPauseState extends State<_PlayPause> with TickerProviderStateMixin {
  final _flCtr = Get.find<FlVideoController>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: GetBuilder<FlVideoController>(
              id: 'flVideoState', builder: (_flCtr) => changeState()),
        ),
      ),
    );
  }

  Widget changeState() {
    switch (_flCtr.flVideoState) {
      case FlVideoState.loading:
        return const SizedBox();
      default:
        return _playPause();
    }
  }

  Widget _playPause() {
    return GetBuilder<FlVideoController>(
      id: 'overlay',
      builder: (_flctr) => InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: _flCtr.overlayVisible ? _flCtr.togglePlayPauseVideo : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _flCtr.playPauseCtr,
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
  }
}
