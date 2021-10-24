import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'package:fl_video_player/src/widgets/custom_overlay.dart';

import 'controllers/fl_video_controller.dart';
import 'utils/fl_enums.dart';
import 'widgets/fl_video_progress_bar.dart';
import 'widgets/full_screen_view.dart';
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
    _flCtr = Get.put(FlVideoController(), permanent: true)
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
    _flCtr.hoverOverlayTimer?.cancel();
    _flCtr.leftDoubleTapTimer?.cancel();
    _flCtr.rightDoubleTapTimer?.cancel();
    Get.delete<FlVideoController>(force: true);
    super.dispose();
  }

  ///
  final circularProgressIndicator = const CircularProgressIndicator(
    backgroundColor: Colors.black87,
    color: Colors.white,
    strokeWidth: 2,
  );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlVideoController>(
      builder: (_) {
        return Center(
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: _flCtr.videoCtr == null
                      ? circularProgressIndicator
                      : _flCtr.videoCtr!.value.isInitialized
                          ? _buildPlayer()
                          : circularProgressIndicator,
                )),
          ),
        );
      },
    );
  }

  Widget _buildPlayer() {
    if (kIsWeb) {
      return GetBuilder<FlVideoController>(
        id: 'full-screen',
        builder: (_flCtr) {
          if (_flCtr.isFullScreen) return circularProgressIndicator;
          return FlPlayer(
            videoPlayerCtr: _flCtr.videoCtr!,
          );
        },
      );
    } else {
      return FlPlayer(
        videoPlayerCtr: _flCtr.videoCtr!,
      );
    }
  }
}

class FlPlayer extends StatelessWidget {
  final VideoPlayerController videoPlayerCtr;
  const FlPlayer({
    Key? key,
    required this.videoPlayerCtr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(videoPlayerCtr),
        const _VideoOverlays(),
        GetBuilder<FlVideoController>(
          id: 'flVideoState',
          builder: (_flCtr) => _flCtr.flVideoState == FlVideoState.loading
              ? const Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  strokeWidth: 2,
                ))
              //TODO: web play pause like youtube
              : const SizedBox(),
        ),
        if (!kIsWeb)
          GetBuilder<FlVideoController>(
            id: 'full-screen',
            builder: (_flCtr) => _flCtr.isFullScreen
                ? const SizedBox()
                : const Align(
                    alignment: Alignment.bottomCenter,
                    child: FlVideoProgressBar(
                      allowGestures: true,
                      height: 5,
                    ),
                  ),
          ),
      ],
    );
  }
}

class _VideoOverlays extends StatelessWidget {
  const _VideoOverlays({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlVideoController>(
      id: 'overlay',
      builder: (_flCtr) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _flCtr.isOverlayVisible ? 1 : 0,
          child: Stack(
            fit: StackFit.expand,
            children: const [
              if (!kIsWeb) MobileOverlay(),
              if (kIsWeb) WebOverlay(),
            ],
          ),
        );
      },
    );
  }
}

class WebOverlay extends StatelessWidget {
  const WebOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final _flCtr = Get.find<FlVideoController>();
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: VideoOverlayDetector(
                  onTap: _flCtr.togglePlayPauseVideo,
                  child: ColoredBox(
                    color: overlayColor,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              // VideoOverlayDetector(
              //   onTap: _flCtr.togglePlayPauseVideo,
              //   child: ColoredBox(
              //     color: overlayColor,
              //     child: const _PlayPause(),
              //   ),
              // ),
              Expanded(
                child: VideoOverlayDetector(
                  onTap: _flCtr.togglePlayPauseVideo,
                  child: ColoredBox(
                    color: overlayColor,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomLeft,
          child: _WebOverlayBottomControlles(),
        ),
      ],
    );
  }

  // void _bottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => const _MobileBottomSheet(),
  //   );
  // }
}

class _WebOverlayBottomControlles extends StatelessWidget {
  const _WebOverlayBottomControlles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlVideoController>();
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return MouseRegion(
      onHover: (event) => _flCtr.onOverlayHover(),
      onExit: (event) => _flCtr.onOverlayHoverExit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FlVideoProgressBar(allowGestures: true),
            Row(
              children: [
                const _PlayPause(),
                GetBuilder<FlVideoController>(
                  id: 'volume',
                  builder: (_flCtr) => MaterialIconButton(
                    color: itemColor,
                    onPressed: _flCtr.toggleMute,
                    child: Icon(
                      _flCtr.isMute
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                    ),
                  ),
                ),
                GetBuilder<FlVideoController>(
                    id: 'video-progress',
                    builder: (_flCtr) {
                      return Text(
                        _flCtr.calculateVideoDuration(_flCtr.videoPosition),
                        style: durationTextStyle,
                      );
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
                const _WebSettingsDropdown(),
                MaterialIconButton(
                  color: itemColor,
                  onPressed: () {
                    if (_flCtr.isOverlayVisible) {
                      if (_flCtr.isFullScreen) {
                        _exitFullScreen(context);
                      } else {
                        _fullScreen(context);
                      }
                    } else {
                      _flCtr.toggleVideoOverlay();
                    }
                  },
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
        opaque: true,
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
}

class _WebSettingsDropdown extends StatefulWidget {
  const _WebSettingsDropdown({
    Key? key,
  }) : super(key: key);

  @override
  State<_WebSettingsDropdown> createState() => _WebSettingsDropdownState();
}

class _WebSettingsDropdownState extends State<_WebSettingsDropdown> {
  late CustomOverlay playBackOverlay;
  late CustomOverlay vimeoQualityOverlay;
  @override
  Widget build(BuildContext context) {
    playBackOverlay = CustomOverlay(
      content: Material(
        child: _VideoPlaybackSelector(
          onTap: () {
            playBackOverlay.close();
          },
        ),
      ),
    );

    vimeoQualityOverlay = CustomOverlay(
      content: Material(child: _VideoQualitySelector(
        onTap: () {
          vimeoQualityOverlay.close();
        },
      )),
    );
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.white,
        selectedRowColor: Colors.white,
      ),
      child: GetBuilder<FlVideoController>(
        builder: (_flCtr) => DropdownButton<dynamic>(
          underline: const ColoredBox(color: Colors.transparent),
          items: [
            if (_flCtr.videoPlayerType == FlVideoPlayerType.vimeo)
              DropdownMenuItem(
                value: '',
                child: Builder(builder: (context) {
                  return _bottomSheetTiles(
                    title: 'Quality',
                    icon: Icons.video_settings_rounded,
                    subText: '${_flCtr.vimeoPlayingVideoQuality}p',
                    onTap: () {
                      Navigator.of(context).pop();
                      vimeoQualityOverlay.show(context);
                    },
                  );
                }),
              ),
            DropdownMenuItem(
              value: '',
              onTap: () {
                _flCtr.toggleLooping();
              },
              child: _bottomSheetTiles(
                title: 'Loop video',
                icon: Icons.loop_rounded,
                subText: _flCtr.isLooping ? 'On' : 'Off',
              ),
            ),
            DropdownMenuItem(
              value: '',
              onTap: () {},
              child: Builder(builder: (context) {
                return _bottomSheetTiles(
                    title: 'Playback speed',
                    icon: Icons.slow_motion_video_rounded,
                    subText: _flCtr.currentPaybackSpeed,
                    onTap: () {
                      Navigator.of(context).pop();
                      playBackOverlay.show(context);
                    });
              }),
            )
          ],
          icon: const MaterialIconButton(
            color: Colors.white,
            // onPressed: _flCtr.toggleMute,
            child: Icon(
              Icons.settings,
            ),
          ),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 20),
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

class MobileOverlay extends StatelessWidget {
  const MobileOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final _flCtr = Get.find<FlVideoController>();
    return Stack(
      alignment: Alignment.center,
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
                child: const SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: _PlayPause(
                      size: 42,
                    ),
                  ),
                ),
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
                    onPressed: () {
                      if (_flCtr.isOverlayVisible) {
                        _bottomSheet(context);
                      } else {
                        _flCtr.toggleVideoOverlay();
                      }
                    },
                    child: const Icon(
                      Icons.more_vert_rounded,
                    ),
                  ),
                ],
              ),
              const _MobileOverlayBottomControlles()
            ],
          ),
        ),
      ],
    );
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _MobileBottomSheet(),
    );
  }
}

class _MobileOverlayBottomControlles extends StatelessWidget {
  const _MobileOverlayBottomControlles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlVideoController>();
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return GetBuilder<FlVideoController>(
      id: 'full-screen',
      builder: (_fl) => Padding(
        padding: _fl.isFullScreen ? const EdgeInsets.all(10) : EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_fl.isFullScreen)
              GetBuilder<FlVideoController>(
                id: 'overlay',
                builder: (_flCtr) => Visibility(
                  visible: _flCtr.isOverlayVisible,
                  child: const FlVideoProgressBar(allowGestures: true),
                ),
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
                  onPressed: () {
                    if (_flCtr.isOverlayVisible) {
                      if (_fl.isFullScreen) {
                        _exitFullScreen(context);
                      } else {
                        _fullScreen(context);
                      }
                    } else {
                      _flCtr.toggleVideoOverlay();
                    }
                  },
                  child: Icon(
                    _fl.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        opaque: true,
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
  final void Function()? onTap;
  const _VideoQualitySelector({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flctr = Get.find<FlVideoController>();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _flctr.vimeoVideoUrls
                ?.map((e) => ListTile(
                      title: Text('${e.quality}p'),
                      onTap: () {
                        onTap != null ? onTap!() : Navigator.of(context).pop();

                        _flctr.changeVimeoVideoQuality(e.quality);
                      },
                    ))
                .toList() ??
            [],
      ),
    );
  }
}

class _VideoPlaybackSelector extends StatelessWidget {
  final void Function()? onTap;
  const _VideoPlaybackSelector({
    Key? key,
    this.onTap,
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
                    onTap != null ? onTap!() : Navigator.of(context).pop();
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
  final double? size;
  const _PlayPause({
    Key? key,
    this.size,
  }) : super(key: key);

  @override
  State<_PlayPause> createState() => _PlayPauseState();
}

class _PlayPauseState extends State<_PlayPause> with TickerProviderStateMixin {
  final _flCtr = Get.find<FlVideoController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlVideoController>(
      id: 'overlay',
      builder: (_flctr) => MaterialIconButton(
        onPressed: _flCtr.isOverlayVisible ? _flCtr.togglePlayPauseVideo : null,
        child: GetBuilder<FlVideoController>(
          id: 'flVideoState',
          builder: (_flCtr) => onStateChange(),
        ),
      ),
    );
  }

  Widget onStateChange() {
    if (kIsWeb) return _playPause();
    switch (_flCtr.flVideoState) {
      case FlVideoState.loading:
        return const SizedBox();
      default:
        return _playPause();
    }
  }

  Widget _playPause() {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _flCtr.playPauseCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
