import 'dart:async';
import 'dart:developer';

import 'package:fl_video_player/src/fl_enums.dart';
import 'package:fl_video_player/src/vimeo_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'vimeo_video_api.dart';

class FlVideoController extends GetxController {
  VideoPlayerController? videoCtr;
  late AnimationController playPauseCtr;
  late FlVideoPlayerType videoPlayerType;
  FlVideoState flVideoState = FlVideoState.loading;
  late String initUrl;
  List<VimeoVideoQalityUrls>? vimeoVideoUrls;
  bool showOverlay = true;

  //double tap
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  int leftDubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  ///
  bool isvideoPlaying = false;

  void videoListner() {}

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

  void isShowOverlay(bool val, {Duration? delay}) {
    Future.delayed(delay ?? Duration.zero).then((_) {
      showOverlay = val;
      update(['overlay']);
    });
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(String quality) {
    return vimeoVideoUrls
        ?.firstWhere((element) => element.quality == quality)
        .urls;
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

  ///config vimeo player
  Future<void> vimeoPlayerinit(String videoId) async {
    await getVimeoVideoUrls(videoId: videoId);
    initUrl = getQualityUrl(vimeoVideoUrls?.last.quality ?? '720p')!;
  }

  ///updates state with id `flVideoState`
  void flVideoStateChanger(FlVideoState _val) {
    flVideoState = _val;
    update(['flVideoState']);
  }

  ///toogle play pause
  void playPauseVideo() {
    isvideoPlaying = !isvideoPlaying;
    playVideo(isvideoPlaying);
  }

  ///controll play pause
  Future<void> playVideo(bool val) async {
    isvideoPlaying = val;
    if (isvideoPlaying) {
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

  ///handle double tap
  void onLeftDoubleTap() {
    isShowOverlay(true);
    leftDoubleTapTimer?.cancel();
    updateLeftTapDuration(leftDubleTapduration += 10);
    isLeftDbTapIconVisible = true;
    leftDoubleTapTimer = Timer(const Duration(seconds: 1), () {
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
    rightDoubleTapTimer = Timer(const Duration(seconds: 1), () {
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      isShowOverlay(false);
    });
  }

  ///update doubletap durations
  void updateLeftTapDuration(int val) {
    leftDubleTapduration = val;
    update(['left-tap']);
  }

  void updateRightTapDuration(int val) {
    rightDubleTapduration = val;
    update(['right-tap']);
  }
}
