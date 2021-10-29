import 'dart:async';
import 'dart:developer';

import 'package:fl_video_player/src/widgets/custom_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:video_player/video_player.dart';

import '../main.dart';
import '../utils/fl_enums.dart';
import '../utils/vimeo_models.dart';
import '../utils/vimeo_video_api.dart';
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

  static final player =
      FlPlayer(videoPlayerCtr: Get.find<FlVideoController>().videoCtr!);

  ///*init
  Future<void> videoInit({
    String? videoUrl,
    String? vimeoVideoId,
    bool isLooping = false,
    int? vimeoVideoQuality,
    required BuildContext context,
  }) async {
    if (kIsWeb) {
      ///this will listne to fullScreen and exitFullScreen state in web
      _html.document.documentElement?.onFullscreenChange.listen((event) {
        if (isFullScreen) {
          closeCustomOverlays();
          exitFullScreenView(context);
        } else {
          closeCustomOverlays();
          enableFullScreenView(context);
        }
      });
    }
    checkPlayerType(videoUrl: videoUrl, vimeoVideoId: vimeoVideoId);
    try {
      if (_videoPlayerType == FlVideoPlayerType.vimeo) {
        await vimeoPlayerInit(
          vimeoVideoId!,
          vimeoVideoQuality,
        );
      } else {
        _playingVideoUrl = videoUrl!;
      }
      _videoCtr = VideoPlayerController.network(
        _playingVideoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooping);
      _videoCtr?.addListener(videoListner);
      update();
    } catch (e) {
      log('cathed $e');
      rethrow;
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
  void checkPlayerType({String? vimeoVideoId, String? videoUrl}) {
    if (vimeoVideoId != null) {
      _videoPlayerType = FlVideoPlayerType.vimeo;
      return;
    } else {
      if (videoUrl == null) {
        throw Exception('videoUrl is required');
      }
      _videoPlayerType = FlVideoPlayerType.general;
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
