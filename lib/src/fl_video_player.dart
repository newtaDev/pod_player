import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:universal_html/html.dart' as _html;

import '../fl_video_player.dart';
import 'controllers/fl_getx_video_controller.dart';
import 'utils/logger.dart';
import 'widgets/material_icon_button.dart';

part 'widgets/core/fl_core_player.dart';
part 'widgets/core/overlays/mob_bottom_overlay_controller.dart';
part 'widgets/core/overlays/mobile_bottomsheet.dart';
part 'widgets/core/overlays/mobile_overlay.dart';
part 'widgets/core/overlays/overlays.dart';
part 'widgets/core/overlays/web_bottom_overlay_controller.dart';
part 'widgets/core/overlays/web_dropdown_menu.dart';
part 'widgets/core/overlays/web_overlay.dart';
part 'widgets/core/video_gesture_detector.dart';
part 'widgets/full_screen_view.dart';

class FlVideoPlayer extends StatefulWidget {
  final FlVideoController controller;
  final double frameAspectRatio;
  final double videoAspectRatio;
  final bool alwaysShowProgressBar;
  final bool matchVideoAspectRatioToVideo;
  final bool matchFrameAspectRatioToVideo;
  final FlProgressBarConfig flProgressBarConfig;
  final Widget Function(OverLayOptions options)? overlayBuilder;
  final Widget? videoTitle;
  FlVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
    this.alwaysShowProgressBar = true,
    this.flProgressBarConfig = const FlProgressBarConfig(),
    this.overlayBuilder,
    this.videoTitle,
    this.matchVideoAspectRatioToVideo = false,
    this.matchFrameAspectRatioToVideo = false,
  }) : super(key: key) {
    addToUiController();
  }

  void addToUiController() {
    Get.find<FlGetXVideoController>(tag: controller.getTag)

      ///add to ui
      ..alwaysShowProgressBar = alwaysShowProgressBar
      ..flProgressBarConfig = flProgressBarConfig
      ..overlayBuilder = overlayBuilder
      ..videoTitle = videoTitle;
  }

  @override
  State<FlVideoPlayer> createState() => _FlVideoPlayerState();
}

class _FlVideoPlayerState extends State<FlVideoPlayer>
    with TickerProviderStateMixin {
  late FlGetXVideoController _flCtr;
  // late String tag;
  @override
  void initState() {
    super.initState();
    // tag = widget.controller?.tag ?? UniqueKey().toString();
    _flCtr = Get.put(
      FlGetXVideoController(),
      permanent: true,
      tag: widget.controller.getTag,
    )..isVideoUiBinded = true;
    if (_flCtr.wasVideoPlayingOnUiDispose ?? false) {
      _flCtr.flVideoStateChanger(FlVideoState.playing, updateUi: false);
    }
    if (kIsWeb) {
      if (widget.controller.playerConfig.forcedVideoFocus) {
        _flCtr.keyboardFocusWeb = FocusNode();
        _flCtr.keyboardFocusWeb?.addListener(_flCtr.keyboadListner);
      }
      //to disable mouse right click
      _html.document.onContextMenu.listen((event) => event.preventDefault());
    }
  }

  @override
  void dispose() {
    super.dispose();

    ///Checking if the video was playing when this widget is disposed
    if (_flCtr.isvideoPlaying) {
      _flCtr.wasVideoPlayingOnUiDispose = true;
    } else {
      _flCtr.wasVideoPlayingOnUiDispose = false;
    }
    _flCtr
      ..isVideoUiBinded = false
      ..flVideoStateChanger(FlVideoState.paused, updateUi: false);
    if (kIsWeb) {
      _flCtr.keyboardFocusWeb?.removeListener(_flCtr.keyboadListner);
    }
    // _flCtr.keyboardFocus?.unfocus();
    // _flCtr.keyboardFocusOnFullScreen?.unfocus();
    _flCtr.hoverOverlayTimer?.cancel();
    _flCtr.showOverlayTimer?.cancel();
    _flCtr.showOverlayTimer1?.cancel();
    _flCtr.leftDoubleTapTimer?.cancel();
    _flCtr.rightDoubleTapTimer?.cancel();
  }

  ///
  final circularProgressIndicator = const CircularProgressIndicator(
    backgroundColor: Colors.black87,
    color: Colors.white,
    strokeWidth: 2,
  );
  @override
  Widget build(BuildContext context) {
    _flCtr.mainContext = context;
    return GetBuilder<FlGetXVideoController>(
      tag: widget.controller.getTag,
      builder: (_) {
        final _frameAspectRatio = widget.matchFrameAspectRatioToVideo
            ? _flCtr.videoCtr?.value.aspectRatio ?? widget.frameAspectRatio
            : widget.frameAspectRatio;
        return Center(
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: _frameAspectRatio,
              child: Center(
                child: _flCtr.videoCtr == null
                    ? circularProgressIndicator
                    : _flCtr.videoCtr!.value.isInitialized
                        ? _buildPlayer()
                        : circularProgressIndicator,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayer() {
    final _videoAspectRatio = widget.matchVideoAspectRatioToVideo
        ? _flCtr.videoCtr?.value.aspectRatio ?? widget.videoAspectRatio
        : widget.videoAspectRatio;
    if (kIsWeb) {
      return GetBuilder<FlGetXVideoController>(
        tag: widget.controller.getTag,
        id: 'full-screen',
        builder: (_flCtr) {
          if (_flCtr.isFullScreen) return circularProgressIndicator;
          return FlCorePlayer(
            videoPlayerCtr: _flCtr.videoCtr!,
            videoAspectRatio: _videoAspectRatio,
            tag: widget.controller.getTag,
          );
        },
      );
    } else {
      return FlCorePlayer(
        videoPlayerCtr: _flCtr.videoCtr!,
        videoAspectRatio: _videoAspectRatio,
        tag: widget.controller.getTag,
      );
    }
  }
}

class _PlayPause extends StatefulWidget {
  final double? size;
  final String tag;

  const _PlayPause({
    Key? key,
    this.size,
    required this.tag,
  }) : super(key: key);

  @override
  State<_PlayPause> createState() => _PlayPauseState();
}

class _PlayPauseState extends State<_PlayPause>
    with SingleTickerProviderStateMixin {
  late final AnimationController _payCtr;
  late FlGetXVideoController _flCtr;
  @override
  void initState() {
    _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flCtr.addListenerId('flVideoState', playPauseListner);
    if (_flCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (_flCtr.flVideoState == FlVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (_flCtr.flVideoState == FlVideoState.paused) {
        if (mounted) _payCtr.reverse();
      }
    });
  }

  @override
  void dispose() {
    flLog('Play-pause-controller-disposed');
    _payCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: widget.tag,
      id: 'overlay',
      builder: (_flctr) {
        return GetBuilder<FlGetXVideoController>(
          tag: widget.tag,
          id: 'flVideoState',
          builder: (_f) => MaterialIconButton(
            toolTipMesg: _f.isvideoPlaying
                ? 'Pause${kIsWeb ? ' (space)' : ''}'
                : 'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                _flCtr.isOverlayVisible ? _flCtr.togglePlayPauseVideo : null,
            child: onStateChange(_flCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(FlGetXVideoController _flCtr) {
    if (kIsWeb) return _playPause(_flCtr);
    if (_flCtr.flVideoState == FlVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(_flCtr);
    }
  }

  Widget _playPause(FlGetXVideoController _flCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
