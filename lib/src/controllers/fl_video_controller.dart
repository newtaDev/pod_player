import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:video_player/video_player.dart';

import '../utils/fl_enums.dart';
import '../utils/vimeo_models.dart';
import '../utils/vimeo_video_api.dart';
import '../widgets/custom_overlay.dart';
import '../widgets/full_screen_view.dart';

part './fl_base_controller.dart';
part './fl_gestures_controller.dart';
part './fl_player_controller.dart';
part './fl_vimeo_controller.dart';

class FlVideoController extends _FlGesturesController {
  ///main videoplayer controller
  VideoPlayerController? get videoCtr => _videoCtr;

  ///flVideoPlayer state notifier
  FlVideoState get flVideoState => _flVideoState;

  ///vimeo or general --video player type
  FlVideoPlayerType get videoPlayerType => _videoPlayerType;

  String get currentPaybackSpeed => _currentPaybackSpeed;

  ///
  Duration get videoDuration => _videoDuration;

  ///
  Duration get videoPosition => _videoPosition;

  //TODO: convert to getter

  String? fromNetworkUrl;
  String? fromVimeoVideoId;
  String? fromAssets;
  File? fromFile;
  int? vimeoVideoQuality;

  ///*init
  Future<void> videoInit({
    final String? fromNetworkUrl,
    final String? fromVimeoVideoId,
    final String? fromAssets,
    final File? fromFile,
    required final FlVideoPlayerType playerType,
    bool isLooping = false,
    int? vimeoVideoQuality,
    required BuildContext context,
  }) async {
    ///
    this.fromNetworkUrl = fromNetworkUrl;
    this.fromVimeoVideoId = fromVimeoVideoId;
    this.fromAssets = fromAssets;
    this.fromFile = fromFile;
    this.vimeoVideoQuality = vimeoVideoQuality;
    _videoPlayerType = playerType;
    checkPlayerType();
    log(_videoPlayerType.toString());
    try {
      ///
      if (kIsWeb) {
        ///this will listne to fullScreen and exitFullScreen state in web
        _html.document.documentElement?.onFullscreenChange.listen(
          (e) => _webFullScreenListner(context),
        );
      }
      await _initializePlayer();

      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooping);
      _videoCtr?.addListener(videoListner);
      update();
    } catch (e) {
      log('ERROR ON FLVIDEOPLAYER:  $e');
      rethrow;
    }
  }

  Future<void> _initializePlayer() async {
    switch (_videoPlayerType) {
      case FlVideoPlayerType.network:

        ///
        _videoCtr = VideoPlayerController.network(
          fromNetworkUrl!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        break;
      case FlVideoPlayerType.vimeo:

        ///
        await vimeoPlayerInit(
          fromVimeoVideoId!,
          vimeoVideoQuality,
        );

        _videoCtr = VideoPlayerController.network(
          _vimeoVideoUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        break;
      case FlVideoPlayerType.asset:

        ///
        _videoCtr = VideoPlayerController.asset(
          fromAssets!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        break;
      case FlVideoPlayerType.file:

        ///
        _videoCtr = VideoPlayerController.file(
          fromFile!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        break;
      case FlVideoPlayerType.auto:
        assert(
          fromNetworkUrl != null,
          '''---------  fromVideoUrl parameter is required  ---------''',
        );
        _videoCtr = VideoPlayerController.network(
          fromNetworkUrl!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        break;
    }
  }

  ///Listning on keyboard events
  void onKeyBoardEvents({
    required RawKeyEvent event,
    required BuildContext appContext,
  }) {
    if (kIsWeb) {
      if (event.isKeyPressed(LogicalKeyboardKey.space)) {
        togglePlayPauseVideo();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.keyM)) {
        toggleMute();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        onLeftDoubleTap();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        onRightDoubleTap();
        return;
      }

      if (event.isKeyPressed(LogicalKeyboardKey.keyF)) {
        if (isFullScreen) {
          _html.document.exitFullscreen();
        } else {
          _html.document.documentElement?.requestFullscreen();
        }
        return;
      }
    }
  }

  ///this func will listne to update id `_flVideoState`
  void flStateListner() {
    log(_flVideoState.toString());
    switch (_flVideoState) {
      case FlVideoState.playing:
        playVideo(true);
        break;
      case FlVideoState.paused:
        playVideo(false);
        break;
      case FlVideoState.loading:
        isShowOverlay(true);
        break;
      default:
    }
  }

  ///check video player type
  void checkPlayerType() {
    if (_videoPlayerType == FlVideoPlayerType.auto) {
      if (fromVimeoVideoId != null) {
        _videoPlayerType = FlVideoPlayerType.vimeo;
        return;
      }
      if (fromNetworkUrl != null) {
        _videoPlayerType = FlVideoPlayerType.network;
        return;
      }
      if (fromAssets != null) {
        _videoPlayerType = FlVideoPlayerType.asset;
        return;
      }
      if (fromFile != null) {
        _videoPlayerType = FlVideoPlayerType.file;
        return;
      }
      //Default
      _videoPlayerType = FlVideoPlayerType.auto;
    }
  }

  void _webFullScreenListner(BuildContext context) {
    if (isFullScreen) {
      closeCustomOverlays();
      exitFullScreenView(context);
    } else {
      closeCustomOverlays();
      enableFullScreenView(context);
    }
  }


  ///checkes wether video should be `autoplayed` initially
  void checkAutoPlayVideo() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      if (autoPlay) {
        if (kIsWeb) await _videoCtr?.setVolume(0);
        flVideoStateChanger(FlVideoState.playing);
      } else {
        flVideoStateChanger(FlVideoState.paused);
      }
    });
  }
}
