import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;

import '../../fl_video_player.dart';
import '../utils/logger.dart';
import '../utils/vimeo_video_api.dart';

part './fl_base_controller.dart';
part './fl_gestures_controller.dart';
part './fl_player_controller.dart';
part './fl_ui_controller.dart';
part './fl_vimeo_controller.dart';

class FlGetXVideoController extends _FlUiController {
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

  String? fromNetworkUrl;
  String? fromVimeoVideoId;
  String? fromAssets;
  File? fromFile;
  int? vimeoVideoQuality;
  List<VimeoVideoQalityUrls>? fromVimeoUrls;
  bool controllerInitialized = false;

  void config({
    required PlayVideoFrom playVideoFrom,
    bool isLooping = false,
    bool autoPlay = true,
    int? vimeoVideoQuality,
  }) {
    fromNetworkUrl = playVideoFrom.fromNetworkUrl;
    fromVimeoVideoId = playVideoFrom.fromVimeoVideoId;
    fromVimeoUrls = playVideoFrom.fromVimeoUrls;
    fromAssets = playVideoFrom.fromAssets;
    fromFile = playVideoFrom.fromFile;
    this.vimeoVideoQuality = vimeoVideoQuality;
    _videoPlayerType = playVideoFrom.playerType;
    this.autoPlay = autoPlay;
    this.isLooping = isLooping;
  }

  ///*init
  Future<void> videoInit() async {
    ///
    checkPlayerType();
    flLog(_videoPlayerType.toString());
    try {
      await _initializePlayer();
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooping);
      _videoCtr?.addListener(videoListner);
      addListenerId('flVideoState', flStateListner);

      checkAutoPlayVideo();
      controllerInitialized = true;
      update();

      update(['update-all']);
      // ignore: unawaited_futures
      Future.delayed(const Duration(milliseconds: 600))
          .then((value) => _isWebAutoPlayDone = true);
    } catch (e) {
      flLog('ERROR ON FLVIDEOPLAYER:  $e');
      rethrow;
    }
  }

  Future<void> _initializePlayer() async {
    switch (_videoPlayerType) {
      case FlVideoPlayerType.network:

        ///
        _videoCtr = VideoPlayerController.network(fromNetworkUrl!);

        break;
      case FlVideoPlayerType.vimeo:

        ///
        if (fromVimeoVideoId != null) {
          await vimeoPlayerInit(
            quality: vimeoVideoQuality,
            videoId: fromVimeoVideoId,
          );
        } else {
          await vimeoPlayerInit(
            quality: vimeoVideoQuality,
            vimeoUrls: fromVimeoUrls,
          );
        }

        _videoCtr = VideoPlayerController.network(_vimeoVideoUrl);

        break;
      case FlVideoPlayerType.asset:

        ///
        _videoCtr = VideoPlayerController.asset(fromAssets!);
        break;
      case FlVideoPlayerType.file:

        ///
        _videoCtr = VideoPlayerController.file(fromFile!);

        break;
      case FlVideoPlayerType.auto:
        assert(
          fromNetworkUrl != null ||
              fromAssets != null ||
              fromVimeoVideoId != null ||
              fromVimeoUrls != null ||
              fromFile != null,
          '''---------  any one parameter is required  ---------''',
        );
        _videoCtr = VideoPlayerController.network(fromNetworkUrl!);
        break;
    }
  }

  ///Listning on keyboard events
  void onKeyBoardEvents({
    required RawKeyEvent event,
    required BuildContext appContext,
    required String tag,
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
      if (event.isKeyPressed(LogicalKeyboardKey.keyF) &&
          event.logicalKey.keyLabel == 'F') {
        toggleFullScreenOnWeb(appContext, tag);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
        if (isFullScreen) {
          _html.document.exitFullscreen();
          disableFullScreen(appContext, tag);
        }
      }

      return;
    }
  }

  void toggleFullScreenOnWeb(BuildContext context, String tag) {
    if (isFullScreen) {
      _html.document.exitFullscreen();
      disableFullScreen(context, tag);
    } else {
      _html.document.documentElement?.requestFullscreen();
      enableFullScreen(context, tag);
    }
  }

  ///this func will listne to update id `_flVideoState`
  void flStateListner() {
    flLog(_flVideoState.toString());
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
      case FlVideoState.error:
        playVideo(false);
        break;
    }
  }

  ///check video player type
  void checkPlayerType() {
    if (_videoPlayerType == FlVideoPlayerType.auto) {
      if (fromVimeoVideoId != null || fromVimeoUrls != null) {
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

  ///checkes wether video should be `autoplayed` initially
  void checkAutoPlayVideo() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      if (autoPlay && (isVideoUiBinded ?? false)) {
        if (kIsWeb) await _videoCtr?.setVolume(0);
        flVideoStateChanger(FlVideoState.playing);
      } else {
        flVideoStateChanger(FlVideoState.paused);
      }
    });
  }

  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    required FlVideoPlayerConfig playerConfig,
  }) async {
    _videoCtr?.removeListener(videoListner);
    flVideoStateChanger(FlVideoState.paused);
    flVideoStateChanger(FlVideoState.loading);
    keyboardFocusWeb?.removeListener(keyboadListner);
    removeListenerId('flVideoState', flStateListner);
    _isWebAutoPlayDone = false;
    config(
      playVideoFrom: playVideoFrom,
      autoPlay: playerConfig.autoPlay,
      isLooping: playerConfig.isLooping,
    );
    keyboardFocusWeb?.requestFocus();
    keyboardFocusWeb?.addListener(keyboadListner);
    await videoInit();
  }
}
