import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;

import '../pod_player.dart';
import 'controllers/pod_getx_video_controller.dart';
import 'utils/logger.dart';
import 'widgets/double_tap_icon.dart';
import 'widgets/material_icon_button.dart';

part 'widgets/animated_play_pause_icon.dart';

part 'widgets/core/overlays/mobile_bottomsheet.dart';

part 'widgets/core/overlays/mobile_overlay.dart';

part 'widgets/core/overlays/overlays.dart';

part 'widgets/core/overlays/web_dropdown_menu.dart';

part 'widgets/core/overlays/web_overlay.dart';

part 'widgets/core/pod_core_player.dart';

part 'widgets/core/video_gesture_detector.dart';

part 'widgets/full_screen_view.dart';

class PodVideoPlayer extends StatefulWidget {
  final PodPlayerController controller;
  final double frameAspectRatio;
  final double videoAspectRatio;
  final bool alwaysShowProgressBar;
  final bool matchVideoAspectRatioToFrame;
  final bool matchFrameAspectRatioToVideo;
  final PodProgressBarConfig podProgressBarConfig;
  final PodPlayerLabels podPlayerLabels;
  final Widget Function(OverLayOptions options)? overlayBuilder;
  final Widget Function()? onVideoError;
  final Widget? videoTitle;
  final Color? backgroundColor;
  final DecorationImage? videoThumbnail;

  /// Optional callback, fired when full screen mode toggles.
  ///
  /// Important: If this method is set, the configuration of [DeviceOrientation]
  /// and [SystemUiMode] is up to you.
  final Future<void> Function(bool isFullScreen)? onToggleFullScreen;

  /// Sets a custom loading widget.
  /// If no widget is informed, a default [CircularProgressIndicator] will be shown.
  final WidgetBuilder? onLoading;

  PodVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
    this.alwaysShowProgressBar = true,
    this.podProgressBarConfig = const PodProgressBarConfig(),
    this.podPlayerLabels = const PodPlayerLabels(),
    this.overlayBuilder,
    this.videoTitle,
    this.matchVideoAspectRatioToFrame = false,
    this.matchFrameAspectRatioToVideo = false,
    this.onVideoError,
    this.backgroundColor,
    this.videoThumbnail,
    this.onToggleFullScreen,
    this.onLoading,
  }) : super(key: key) {
    addToUiController();
  }

  static bool enableLogs = false;
  static bool enableGetxLogs = false;

  void addToUiController() {
    Get.find<PodGetXVideoController>(tag: controller.getTag)

      ///add to ui controller
      ..podPlayerLabels = podPlayerLabels
      ..alwaysShowProgressBar = alwaysShowProgressBar
      ..podProgressBarConfig = podProgressBarConfig
      ..overlayBuilder = overlayBuilder
      ..videoTitle = videoTitle
      ..onToggleFullScreen = onToggleFullScreen
      ..onLoading = onLoading
      ..videoThumbnail = videoThumbnail;
  }

  @override
  State<PodVideoPlayer> createState() => _PodVideoPlayerState();
}

class _PodVideoPlayerState extends State<PodVideoPlayer>
    with TickerProviderStateMixin {
  late PodGetXVideoController _podCtr;

  // late String tag;
  @override
  void initState() {
    super.initState();
    // tag = widget.controller?.tag ?? UniqueKey().toString();
    _podCtr = Get.put(
      PodGetXVideoController(),
      permanent: true,
      tag: widget.controller.getTag,
    )..isVideoUiBinded = true;
    if (_podCtr.wasVideoPlayingOnUiDispose ?? false) {
      _podCtr.podVideoStateChanger(PodVideoState.playing, updateUi: false);
    }
    if (kIsWeb) {
      if (widget.controller.podPlayerConfig.forcedVideoFocus) {
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
      ..podVideoStateChanger(PodVideoState.paused, updateUi: false);
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
    podLog('local PodVideoPlayer disposed');
  }

  ///
  double _frameAspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    final circularProgressIndicator = _thumbnailAndLoadingWidget();
    _podCtr.mainContext = context;

    final _videoErrorWidget = AspectRatio(
      aspectRatio: _frameAspectRatio,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.yellow,
              size: 32,
            ),
            const SizedBox(height: 20),
            Text(
              widget.podPlayerLabels.error,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
    return GetBuilder<PodGetXVideoController>(
      tag: widget.controller.getTag,
      builder: (_) {
        _frameAspectRatio = widget.matchFrameAspectRatioToVideo
            ? _podCtr.videoCtr?.value.aspectRatio ?? widget.frameAspectRatio
            : widget.frameAspectRatio;
        return Center(
          child: ColoredBox(
            color: widget.backgroundColor ?? Colors.black,
            child: GetBuilder<PodGetXVideoController>(
              tag: widget.controller.getTag,
              id: 'errorState',
              builder: (_podCtr) {
                /// Check if has any error
                if (_podCtr.podVideoState == PodVideoState.error) {
                  return widget.onVideoError?.call() ?? _videoErrorWidget;
                }

                return AspectRatio(
                  aspectRatio: _frameAspectRatio,
                  child: _podCtr.videoCtr?.value.isInitialized ?? false
                      ? _buildPlayer()
                      : Center(child: circularProgressIndicator),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return widget.onLoading?.call(context) ??
        const CircularProgressIndicator(
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2,
        );
  }

  Widget _thumbnailAndLoadingWidget() {
    if (widget.videoThumbnail == null) {
      return _buildLoading();
    }

    return SizedBox.expand(
      child: TweenAnimationBuilder<double>(
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: child,
        ),
        tween: Tween<double>(begin: 0.2, end: 0.7),
        duration: const Duration(milliseconds: 400),
        child: DecoratedBox(
          decoration: BoxDecoration(image: widget.videoThumbnail),
          child: Center(
            child: _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final _videoAspectRatio = widget.matchVideoAspectRatioToFrame
        ? _podCtr.videoCtr?.value.aspectRatio ?? widget.videoAspectRatio
        : widget.videoAspectRatio;
    if (kIsWeb) {
      return GetBuilder<PodGetXVideoController>(
        tag: widget.controller.getTag,
        id: 'full-screen',
        builder: (_podCtr) {
          if (_podCtr.isFullScreen) return _thumbnailAndLoadingWidget();
          return _PodCoreVideoPlayer(
            videoPlayerCtr: _podCtr.videoCtr!,
            videoAspectRatio: _videoAspectRatio,
            tag: widget.controller.getTag,
          );
        },
      );
    } else {
      return _PodCoreVideoPlayer(
        videoPlayerCtr: _podCtr.videoCtr!,
        videoAspectRatio: _videoAspectRatio,
        tag: widget.controller.getTag,
      );
    }
  }
}
