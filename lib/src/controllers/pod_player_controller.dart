import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;

import '../../pod_player.dart';
import 'pod_getx_video_controller.dart';

class PodPlayerController {
  ///
  late PodGetXVideoController _ctr;
  late String getTag;
  bool _isInitialised = false;

  final PlayVideoFrom playVideoFrom;
  final PodPlayerConfig podPlayerConfig;

  PodPlayerController({
    required this.playVideoFrom,
    this.podPlayerConfig = const PodPlayerConfig(),
  }) {
    getTag = UniqueKey().toString();
    Get.config(enableLog: PodVideoPlayer.enableLogs);
    _ctr = Get.put(PodGetXVideoController(), permanent: true, tag: getTag)
      ..config(
        playVideoFrom: playVideoFrom,
        autoPlay: podPlayerConfig.autoPlay,
        isLooping: podPlayerConfig.isLooping,
      );
  }
  //!init
  Future<void> initialise() async {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await _ctr.videoInit();
    });
    await _checkAndWaitTillInitialized();
  }

  Future<void> _checkAndWaitTillInitialized() async {
    if (_ctr.controllerInitialized) {
      _isInitialised = true;
      return;
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkAndWaitTillInitialized();
    }
  }

  String? get videoUrl => _ctr.playingVideoUrl;

  bool get isInitialised => _ctr.videoCtr?.value.isInitialized ?? false;
  bool get isVideoPlaying => _ctr.videoCtr?.value.isPlaying ?? false;
  bool get isVideoBuffering => _ctr.videoCtr?.value.isBuffering ?? false;
  bool get isVideoLooping => _ctr.videoCtr?.value.isLooping ?? false;

  bool get isMute => _ctr.isMute;

  PodVideoState get videoState => _ctr.podVideoState;

  VideoPlayerValue? get videoPlayerValue => _ctr.videoCtr?.value;

  PodVideoPlayerType get videoPlayerType => _ctr.videoPlayerType;

  // Future<void> initialize() async => _ctr.videoCtr?.initialize;

  //! video positions

  ///return total length of the video
  Duration get totalVideoLength => _ctr.videoDuration;

  ///return current position/duration of the video
  Duration get currentVideoPosition => _ctr.videoPosition;

  //! video play/pause

  void play() => _ctr.podVideoStateChanger(PodVideoState.playing);

  void pause() => _ctr.podVideoStateChanger(PodVideoState.paused);

  void togglePlayPause() {
    isVideoPlaying ? pause() : play();
  }

  ///Listen to changes in video
  void addListener(void Function() listner) {
    _checkAndWaitTillInitialized().then(
      (value) => _ctr.videoCtr?.addListener(listner),
    );
  }

  ///remove registred listners
  void removeListener(void Function() listner) {
    _checkAndWaitTillInitialized().then(
      (value) => _ctr.videoCtr?.removeListener(listner),
    );
  }
  //! volume Controllers

  Future<void> mute() async => _ctr.mute();

  Future<void> unMute() async => _ctr.unMute();

  Future<void> toggleVolume() async {
    _ctr.isMute ? await _ctr.unMute() : await _ctr.mute();
  }

  ///Dispose controller
  void dispose() {
    _ctr.videoCtr?.removeListener(_ctr.videoListner);
    _ctr.videoCtr?.dispose();
    _ctr.removeListenerId('podVideoState', _ctr.podStateListner);
    Get.delete<PodGetXVideoController>(
      force: true,
      tag: getTag,
    );
  }

  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    PodPlayerConfig playerConfig = const PodPlayerConfig(),
  }) =>
      _ctr.changeVideo(
        playVideoFrom: playVideoFrom,
        playerConfig: playerConfig,
      );

  //Change double tap duration
  void setDoubeTapForwarDuration(int seconds) =>
      _ctr.doubleTapForwardSeconds = seconds;

  ///Jumps to specific position of the video
  Future<void> videoSeekTo(Duration moment) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.seekTo(moment);
  }

  ///Moves video forward from current duration to `_duration`
  Future<void> videoSeekForward(Duration _duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.seekForward(_duration);
  }

  ///Moves video backward from current duration to `_duration`
  Future<void> videoSeekBackward(Duration _duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.seekBackward(_duration);
  }

  ///on right double tap
  Future<void> doubleTapVideoForward(int seconds) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.onRightDoubleTap(seconds: seconds);
  }

  ///on left double tap
  Future<void> doubleTapVideoBackward(int seconds) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.onLeftDoubleTap(seconds: seconds);
  }

  void enableFullScreen() {
    _html.document.documentElement?.requestFullscreen();
    _ctr.enableFullScreen(getTag);
  }

  void disableFullScreen(BuildContext context) {
    _html.document.exitFullscreen();
    if (!_ctr.isWebPopupOverlayOpen) _ctr.disableFullScreen(context, getTag);
  }

  void onVideoQualityChanged(VoidCallback callback) {
    _ctr.onVimeoVideoQualityChanged = callback;
  }
//TODO: support for playlist
}
