import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;

import '../../pod_player.dart';
import 'pod_getx_video_controller.dart';

bool enableDevLogs = false;

class FlVideoController {
  ///
  late FlGetXVideoController _ctr;
  late String getTag;
  bool _isInitialised = false;

  final PlayVideoFrom playVideoFrom;
  final FlVideoPlayerConfig playerConfig;
  bool enableLogs = false;

  FlVideoController({
    required this.playVideoFrom,
    this.playerConfig = const FlVideoPlayerConfig(),
    this.enableLogs = false,
  }) {
    getTag = UniqueKey().toString();
    enableDevLogs = enableLogs;
    Get.config(enableLog: enableLogs);
    _ctr = Get.put(FlGetXVideoController(), permanent: true, tag: getTag)
      ..config(
        playVideoFrom: playVideoFrom,
        autoPlay: playerConfig.autoPlay,
        isLooping: playerConfig.isLooping,
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

  bool get isInitialised => _ctr.videoCtr?.value.isInitialized ?? false;
  bool get isVideoPlaying => _ctr.videoCtr?.value.isPlaying ?? false;
  bool get isVideoBuffering => _ctr.videoCtr?.value.isBuffering ?? false;
  bool get isVideoLooping => _ctr.videoCtr?.value.isLooping ?? false;

  bool get isMute => _ctr.isMute;

  FlVideoState get videoState => _ctr.flVideoState;

  VideoPlayerValue? get videoPlayerValue => _ctr.videoCtr?.value;

  FlVideoPlayerType get videoPlayerType => _ctr.videoPlayerType;

  // Future<void> initialize() async => _ctr.videoCtr?.initialize;

  //! video positions

  ///return total length of the video
  Duration get totalVideoLength => _ctr.videoDuration;

  ///return current position/duration of the video
  Duration get currentVideoPosition => _ctr.videoPosition;

  //! video play/pause

  void play() => _ctr.flVideoStateChanger(FlVideoState.playing);

  void pause() => _ctr.flVideoStateChanger(FlVideoState.paused);

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
    _ctr.removeListenerId('flVideoState', _ctr.flStateListner);
    Get.delete<FlGetXVideoController>(
      force: true,
      tag: getTag,
    );
  }

  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    FlVideoPlayerConfig playerConfig = const FlVideoPlayerConfig(),
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

  void onVimeoVideoQualityChanged(VoidCallback callback) {
    _ctr.onVimeoVideoQualityChanged = callback;
  }
//TODO: support for playlist
}
