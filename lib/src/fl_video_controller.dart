import 'dart:async';
import 'dart:developer';

import 'package:fl_video_player/src/fl_enums.dart';
import 'package:fl_video_player/src/vimeo_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'vimeo_video_api.dart';

class FlVideoController extends GetxController {
  ///main video controller
  VideoPlayerController? videoCtr;

  ///
  late FlVideoPlayerType videoPlayerType;

  late AnimationController playPauseCtr;

  ///
  FlVideoState flVideoState = FlVideoState.loading;
  bool showOverlay = true;

  ///
  late String playingVideoUrl;

  ///vimeo all quality urls
  List<VimeoVideoQalityUrls>? vimeoVideoUrls;

  //double tap
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  int leftDubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  ///
  bool _isvideoPlaying = false;

  ///**init

  Future<void> videoInit(String? videoUrl, String? vimeoVideoId) async {
    checkPlayerType(
      videoUrl: videoUrl,
      vimeoVideoId: vimeoVideoId,
    );
    try {
      if (videoPlayerType == FlVideoPlayerType.vimeo) {
        await vimeoPlayerInit(vimeoVideoId!);
      } else {
        playingVideoUrl = videoUrl!;
      }
      videoCtr = VideoPlayerController.network(playingVideoUrl);
      await videoCtr?.initialize();
      videoCtr?.addListener(videoListner);
    } catch (e) {
      log('cathed $e');
      rethrow;
    }
  }

  void videoListner() {
    //
    _listneVideoState();
  }

  void _listneVideoState() {
    // playVideo(videoCtr!.value.isPlaying);

    flVideoStateChanger(
      videoCtr!.value.isBuffering || !videoCtr!.value.isInitialized
          ? FlVideoState.loading
          : videoCtr!.value.isPlaying
              ? FlVideoState.playing
              : FlVideoState.paused,
    );
  }

  void flStateListner() {
    log(flVideoState.toString());
    switch (flVideoState) {
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

  ///*seek video
  /// Seek video to a duration.
  Future<void> seekTo(Duration moment) async {
    await videoCtr!.seekTo(moment);
  }

  /// Seek video forward by the duration.
  Future<void> seekForward(Duration videoSeekDuration) async {
    await seekTo(videoCtr!.value.position + videoSeekDuration);
  }

  /// Seek video backward by the duration.
  Future<void> seekBackward(Duration videoSeekDuration) async {
    await seekTo(videoCtr!.value.position - videoSeekDuration);
  }

  ///*controll play pause
  Future<void> playVideo(bool val) async {
    _isvideoPlaying = val;
    if (_isvideoPlaying) {
      isShowOverlay(true);
      // ignore: unawaited_futures
      videoCtr?.play();
      await playPauseCtr.forward();
      isShowOverlay(false, delay: const Duration(seconds: 1));
    } else {
      isShowOverlay(true);
      // ignore: unawaited_futures
      videoCtr?.pause();
      await playPauseCtr.reverse();
    }
  }

  ///toogle play pause
  void playPauseVideo() {
    _isvideoPlaying = !_isvideoPlaying;
    flVideoStateChanger(
        _isvideoPlaying ? FlVideoState.playing : FlVideoState.paused);
  }

  ///*handle double tap
  void onLeftDoubleTap() {
    isShowOverlay(true);
    leftDoubleTapTimer?.cancel();
    isLeftDbTapIconVisible = true;
    updateLeftTapDuration(leftDubleTapduration += 10);
    seekBackward(Duration(seconds: rightDubleTapduration));
    leftDoubleTapTimer = Timer(const Duration(milliseconds: 1500), () {
      isLeftDbTapIconVisible = false;
      updateLeftTapDuration(0);
      leftDoubleTapTimer?.cancel();
      isShowOverlay(false);
    });
  }

  void onRightDoubleTap() {
    isShowOverlay(true);
    rightDoubleTapTimer?.cancel();
    isRightDbTapIconVisible = true;
    updateRightTapDuration(rightDubleTapduration += 10);
    seekForward(Duration(seconds: rightDubleTapduration));
    rightDoubleTapTimer = Timer(const Duration(milliseconds: 1500), () {
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      isShowOverlay(false);
    });
  }

  ///update doubletap durations
  void updateLeftTapDuration(int val) {
    leftDubleTapduration = val;
    update(['double-tap']);
  }

  void updateRightTapDuration(int val) {
    rightDubleTapduration = val;
    update(['double-tap']);
  }

  ///*vimeo player configs
  ///
  ///get all  `quality urls`
  Future<void> getVimeoVideoUrls({required String videoId}) async {
    try {
      flVideoStateChanger(FlVideoState.loading);
      vimeoVideoUrls = await VimeoVideoApi.getvideoQualityLink(videoId);
    } catch (e) {
      flVideoStateChanger(FlVideoState.error);

      rethrow;
    }
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(String quality) {
    return vimeoVideoUrls
        ?.firstWhere((element) => element.quality == quality)
        .urls;
  }

  ///config vimeo player
  Future<void> vimeoPlayerInit(String videoId) async {
    await getVimeoVideoUrls(videoId: videoId);
    playingVideoUrl = getQualityUrl(vimeoVideoUrls?.last.quality ?? '720p')!;
  }

  ///*General

  ///toogle video player controls
  void isShowOverlay(bool val, {Duration? delay}) {
    Future.delayed(delay ?? Duration.zero).then((_) {
      showOverlay = val;
      update(['overlay']);
    });
  }

  ///overlay above video contrller
  Future<void> toggleVideoOverlay() async {
    if (!showOverlay) {
      showOverlay = true;
    } else {
      showOverlay = false;
    }
    update(['overlay']);

    if (showOverlay) {
      await Future.delayed(const Duration(seconds: 2)).then((_) {
        if (showOverlay) showOverlay = false;
        update(['overlay']);
      });
      return;
    }
  }

  ///updates state with id `flVideoState`
  void flVideoStateChanger(FlVideoState? _val) {
    if (flVideoState != (_val ?? flVideoState)) {
      flVideoState = _val ?? flVideoState;
      update(['flVideoState']);
    }
  }

  ///check video player type
  void checkPlayerType({String? vimeoVideoId, String? videoUrl}) {
    if (vimeoVideoId != null) {
      videoPlayerType = FlVideoPlayerType.vimeo;
      return;
    } else {
      if (videoUrl == null) {
        throw Exception('videoUrl is required');
      }
      videoPlayerType = FlVideoPlayerType.general;
    }
  }
}
