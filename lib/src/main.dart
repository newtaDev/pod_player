import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:video_player/video_player.dart';

import '../fl_video_player.dart';
import 'controllers/fl_getx_video_controller.dart';
import 'utils/fl_enums.dart';
import 'widgets/fl_video_progress_bar.dart';
import 'widgets/material_icon_button.dart';

part 'widgets/core/fl_core_player.dart';
part 'widgets/core/overlays/mobile_bottomsheet.dart';
part 'widgets/core/overlays/overlays.dart';
part 'widgets/full_screen_view.dart';
part 'widgets/core/overlays/web_dropdown_menu.dart';
part 'widgets/core/overlays/mob_bottom_overlay_controller.dart';
part 'widgets/core/overlays/mobile_overlay.dart';
part 'widgets/core/video_gesture_detector.dart';
part 'widgets/core/overlays/web_bottom_overlay_controller.dart';
part 'widgets/core/overlays/web_overlay.dart';

class FlVideoPlayer extends StatefulWidget {
  final FlVideoController controller;
  final double frameAspectRatio;
  final double videoAspectRatio;

  FlVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
  }) : super(key: key) {
    _validate();
  }

  void _validate() {
    final flVideoController =
        Get.find<FlGetXVideoController>(tag: controller.getTag);

    switch (flVideoController.videoPlayerType) {
      case FlVideoPlayerType.network:
        assert(
          flVideoController.fromNetworkUrl != null,
          '''---------  FlVideoController( fromVideoUrl: )-------- parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.asset:
        assert(
          flVideoController.fromAssets != null,
          '''---------  FlVideoController( fromAssets: )-------- parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.vimeo:
        assert(
          flVideoController.fromVimeoVideoId != null ||
              flVideoController.fromVimeoUrls != null,
          '''---------  FlVideoController( fromVimeoVideoId: )-------- parameter is required  --------- OR  ---------  FlVideoController( fromVimeoUrls: )-------- parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.file:
        assert(
          flVideoController.fromFile != null,
          '''---------  FlVideoController( fromFile: )--------  parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.auto:
        assert(
          flVideoController.fromNetworkUrl != null ||
              flVideoController.fromAssets != null ||
              flVideoController.fromVimeoVideoId != null ||
              flVideoController.fromVimeoUrls != null ||
              flVideoController.fromFile != null,
          '''--------- add required parameters to FlVideoController  ---------''',
        );
        break;
    }
  }

  @override
  _FlVideoPlayerState createState() => _FlVideoPlayerState();
}

class _FlVideoPlayerState extends State<FlVideoPlayer>
    with SingleTickerProviderStateMixin {
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
    )
      ..playPauseCtr = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      )
      ..webFullScreenListner(context, widget.controller.getTag);

    if (kIsWeb) {
      //to disable mouse right click
      _html.document.onContextMenu.listen((event) => event.preventDefault());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _flCtr.flVideoStateChanger(FlVideoState.paused);
    _flCtr.hoverOverlayTimer?.cancel();
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
    return GetBuilder<FlGetXVideoController>(
      tag: widget.controller.getTag,
      builder: (_) {
        return Center(
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: widget.frameAspectRatio,
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
    if (kIsWeb) {
      return GetBuilder<FlGetXVideoController>(
        tag: widget.controller.getTag,
        id: 'full-screen',
        builder: (_flCtr) {
          if (_flCtr.isFullScreen) return circularProgressIndicator;
          return FlCorePlayer(
            videoPlayerCtr: _flCtr.videoCtr!,
            videoAspectRatio: widget.videoAspectRatio,
            tag: widget.controller.getTag,
          );
        },
      );
    } else {
      return FlCorePlayer(
        videoPlayerCtr: _flCtr.videoCtr!,
        videoAspectRatio: widget.videoAspectRatio,
        tag: widget.controller.getTag,
      );
    }
  }
}

class _PlayPause extends StatelessWidget {
  final double? size;
  final String tag;

  const _PlayPause({
    Key? key,
    this.size,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'overlay',
      builder: (_flctr) {
        return GetBuilder<FlGetXVideoController>(
          tag: tag,
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
      progress: _flCtr.playPauseCtr,
      color: Colors.white,
      size: size,
    );
  }
}
