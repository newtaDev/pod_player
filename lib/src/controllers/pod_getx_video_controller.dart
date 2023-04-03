import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:wakelock/wakelock.dart';

import '../../pod_player.dart';
import '../utils/logger.dart';
import '../utils/video_apis.dart';

part 'pod_base_controller.dart';
part 'pod_gestures_controller.dart';
part 'pod_ui_controller.dart';
part 'pod_video_controller.dart';
part 'pod_video_quality_controller.dart';

class PodGetXVideoController extends _PodGesturesController {
  ///main videoplayer controller
  VideoPlayerController? get videoCtr => _videoCtr;

  ///podVideoPlayer state notifier
  PodVideoState get podVideoState => _podVideoState;

  ///vimeo or general --video player type
  PodVideoPlayerType get videoPlayerType => _videoPlayerType;

  String get currentPaybackSpeed => _currentPaybackSpeed;

  ///
  Duration get videoDuration => _videoDuration;

  ///
  Duration get videoPosition => _videoPosition;

  bool controllerInitialized = false;
  late PodPlayerConfig podPlayerConfig;
  late PlayVideoFrom playVideoFrom;
  void config({
    required PlayVideoFrom playVideoFrom,
    required PodPlayerConfig playerConfig,
  }) {
    this.playVideoFrom = playVideoFrom;
    _videoPlayerType = playVideoFrom.playerType;
    podPlayerConfig = playerConfig;
    autoPlay = playerConfig.autoPlay;
    isLooping = playerConfig.isLooping;
  }

  ///*init
  Future<void> videoInit() async {
    ///
    // checkPlayerType();
    podLog(_videoPlayerType.toString());
    try {
      await _initializePlayer();
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooping);
      _videoCtr?.addListener(videoListner);
      addListenerId('podVideoState', podStateListner);

      checkAutoPlayVideo();
      controllerInitialized = true;
      update();

      update(['update-all']);
      // ignore: unawaited_futures
      Future.delayed(const Duration(milliseconds: 600))
          .then((value) => _isWebAutoPlayDone = true);
    } catch (e) {
      podVideoStateChanger(PodVideoState.error);
      update(['errorState']);
      update(['update-all']);
      podLog('ERROR ON POD_PLAYER:  $e');
      rethrow;
    }
  }

  Future<void> _initializePlayer() async {
    switch (_videoPlayerType) {
      case PodVideoPlayerType.network:

        ///
        _videoCtr = VideoPlayerController.network(
          playVideoFrom.dataSource!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = playVideoFrom.dataSource;
        break;
      case PodVideoPlayerType.networkQualityUrls:
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: podPlayerConfig.videoQualityPriority,
          videoUrls: playVideoFrom.videoQualityUrls!,
        );

        ///
        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
      case PodVideoPlayerType.youtube:
        final _urls = await getVideoQualityUrlsFromYoutube(
          playVideoFrom.dataSource!,
          playVideoFrom.live,
        );
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: podPlayerConfig.videoQualityPriority,
          videoUrls: _urls,
        );

        ///
        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
      case PodVideoPlayerType.vimeo:
        await getQualityUrlsFromVimeoId(
          playVideoFrom.dataSource!,
          hash: playVideoFrom.hash,
        );
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: podPlayerConfig.videoQualityPriority,
          videoUrls: vimeoOrVideoUrls,
        );

        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
      case PodVideoPlayerType.asset:

        ///
        _videoCtr = VideoPlayerController.asset(
          playVideoFrom.dataSource!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          package: playVideoFrom.package,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );
        playingVideoUrl = playVideoFrom.dataSource;

        break;
      case PodVideoPlayerType.file:
        if (kIsWeb) {
          throw Exception('file doesnt support web');
        }

        ///
        _videoCtr = VideoPlayerController.file(
          playVideoFrom.file!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );

        break;
      case PodVideoPlayerType.vimeoPrivateVideos:
        await getQualityUrlsFromVimeoPrivateId(
          playVideoFrom.dataSource!,
          playVideoFrom.httpHeaders,
        );
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: podPlayerConfig.videoQualityPriority,
          videoUrls: vimeoOrVideoUrls,
        );

        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

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
          if (!isWebPopupOverlayOpen) {
            disableFullScreen(appContext, tag);
          }
        }
      }

      return;
    }
  }

  void toggleFullScreenOnWeb(BuildContext context, String tag) {
    if (isFullScreen) {
      _html.document.exitFullscreen();
      if (!isWebPopupOverlayOpen) {
        disableFullScreen(context, tag);
      }
    } else {
      _html.document.documentElement?.requestFullscreen();
      enableFullScreen(tag);
    }
  }

  ///this func will listne to update id `_podVideoState`
  void podStateListner() {
    podLog(_podVideoState.toString());
    switch (_podVideoState) {
      case PodVideoState.playing:
        if (podPlayerConfig.wakelockEnabled) Wakelock.enable();
        playVideo(true);
        break;
      case PodVideoState.paused:
        if (podPlayerConfig.wakelockEnabled) Wakelock.disable();
        playVideo(false);
        break;
      case PodVideoState.loading:
        isShowOverlay(true);
        break;
      case PodVideoState.error:
        if (podPlayerConfig.wakelockEnabled) Wakelock.disable();
        playVideo(false);
        break;
    }
  }

  ///checkes wether video should be `autoplayed` initially
  void checkAutoPlayVideo() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (autoPlay && (isVideoUiBinded ?? false)) {
        if (kIsWeb) await _videoCtr?.setVolume(0);
        podVideoStateChanger(PodVideoState.playing);
      } else {
        podVideoStateChanger(PodVideoState.paused);
      }
    });
  }

  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    required PodPlayerConfig playerConfig,
  }) async {
    _videoCtr?.removeListener(videoListner);
    podVideoStateChanger(PodVideoState.paused);
    podVideoStateChanger(PodVideoState.loading);
    keyboardFocusWeb?.removeListener(keyboadListner);
    removeListenerId('podVideoState', podStateListner);
    _isWebAutoPlayDone = false;
    vimeoOrVideoUrls = [];
    config(playVideoFrom: playVideoFrom, playerConfig: playerConfig);
    keyboardFocusWeb?.requestFocus();
    keyboardFocusWeb?.addListener(keyboadListner);
    await videoInit();
  }
}
