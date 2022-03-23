import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:universal_html/html.dart' as _html;

import '../pod_player.dart';
import 'controllers/pod_getx_video_controller.dart';
import 'utils/logger.dart';
import 'widgets/material_icon_button.dart';

part 'widgets/core/pod_core_player.dart';
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
  final FlProgressBarConfig podProgressBarConfig;
  final Widget Function(OverLayOptions options)? overlayBuilder;
  final Widget? videoTitle;
  FlVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
    this.alwaysShowProgressBar = true,
    this.podProgressBarConfig = const FlProgressBarConfig(),
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
      ..podProgressBarConfig = podProgressBarConfig
      ..overlayBuilder = overlayBuilder
      ..videoTitle = videoTitle;
  }

  @override
  State<FlVideoPlayer> createState() => _FlVideoPlayerState();
}

class _FlVideoPlayerState extends State<FlVideoPlayer>
    with TickerProviderStateMixin {
  late FlGetXVideoController _podCtr;
  // late String tag;
  @override
  void initState() {
    super.initState();
    // tag = widget.controller?.tag ?? UniqueKey().toString();
    _podCtr = Get.put(
      FlGetXVideoController(),
      permanent: true,
      tag: widget.controller.getTag,
    )..isVideoUiBinded = true;
    if (_podCtr.wasVideoPlayingOnUiDispose ?? false) {
      _podCtr.podVideoStateChanger(FlVideoState.playing, updateUi: false);
    }
    if (kIsWeb) {
      if (widget.controller.playerConfig.forcedVideoFocus) {
        _podCtr.keyboardFocusWeb = FocusNode();
        _podCtr.keyboardFocusWeb?.addListener(_podCtr.keyboadListner);
      }
      //to disable mouse right click
      _html.document.onContextMenu.listen((event) => event.preventDefault());
    }
  }

  @override
  void dispose() {
    super.dispose();

    ///Checking if the video was playing when this widget is disposed
    if (_podCtr.isvideoPlaying) {
      _podCtr.wasVideoPlayingOnUiDispose = true;
    } else {
      _podCtr.wasVideoPlayingOnUiDispose = false;
    }
    _podCtr
      ..isVideoUiBinded = false
      ..podVideoStateChanger(FlVideoState.paused, updateUi: false);
    if (kIsWeb) {
      _podCtr.keyboardFocusWeb?.removeListener(_podCtr.keyboadListner);
    }
    // _podCtr.keyboardFocus?.unfocus();
    // _podCtr.keyboardFocusOnFullScreen?.unfocus();
    _podCtr.hoverOverlayTimer?.cancel();
    _podCtr.showOverlayTimer?.cancel();
    _podCtr.showOverlayTimer1?.cancel();
    _podCtr.leftDoubleTapTimer?.cancel();
    _podCtr.rightDoubleTapTimer?.cancel();
  }

  ///
  final circularProgressIndicator = const CircularProgressIndicator(
    backgroundColor: Colors.black87,
    color: Colors.white,
    strokeWidth: 2,
  );
  @override
  Widget build(BuildContext context) {
    _podCtr.mainContext = context;
    return GetBuilder<FlGetXVideoController>(
      tag: widget.controller.getTag,
      builder: (_) {
        final _frameAspectRatio = widget.matchFrameAspectRatioToVideo
            ? _podCtr.videoCtr?.value.aspectRatio ?? widget.frameAspectRatio
            : widget.frameAspectRatio;
        return Center(
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: _frameAspectRatio,
              child: Center(
                child: _podCtr.videoCtr == null
                    ? circularProgressIndicator
                    : _podCtr.videoCtr!.value.isInitialized
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
        ? _podCtr.videoCtr?.value.aspectRatio ?? widget.videoAspectRatio
        : widget.videoAspectRatio;
    if (kIsWeb) {
      return GetBuilder<FlGetXVideoController>(
        tag: widget.controller.getTag,
        id: 'full-screen',
        builder: (_podCtr) {
          if (_podCtr.isFullScreen) return circularProgressIndicator;
          return FlCorePlayer(
            videoPlayerCtr: _podCtr.videoCtr!,
            videoAspectRatio: _videoAspectRatio,
            tag: widget.controller.getTag,
          );
        },
      );
    } else {
      return FlCorePlayer(
        videoPlayerCtr: _podCtr.videoCtr!,
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
  late FlGetXVideoController _podCtr;
  @override
  void initState() {
    _podCtr = Get.find<FlGetXVideoController>(tag: widget.tag);
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _podCtr.addListenerId('podVideoState', playPauseListner);
    if (_podCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (_podCtr.podVideoState == FlVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (_podCtr.podVideoState == FlVideoState.paused) {
        if (mounted) _payCtr.reverse();
      }
    });
  }

  @override
  void dispose() {
    podLog('Play-pause-controller-disposed');
    _payCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: widget.tag,
      id: 'overlay',
      builder: (_podCtr) {
        return GetBuilder<FlGetXVideoController>(
          tag: widget.tag,
          id: 'podVideoState',
          builder: (_f) => MaterialIconButton(
            toolTipMesg: _f.isvideoPlaying
                ? 'Pause${kIsWeb ? ' (space)' : ''}'
                : 'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                _podCtr.isOverlayVisible ? _podCtr.togglePlayPauseVideo : null,
            child: onStateChange(_podCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(FlGetXVideoController _podCtr) {
    if (kIsWeb) return _playPause(_podCtr);
    if (_podCtr.podVideoState == FlVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(_podCtr);
    }
  }

  Widget _playPause(FlGetXVideoController _podCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
