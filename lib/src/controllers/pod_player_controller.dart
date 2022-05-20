import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:wakelock/wakelock.dart';

import '../../pod_player.dart';
import '../utils/video_apis.dart';
import 'pod_getx_video_controller.dart';

class PodPlayerController {
  late PodGetXVideoController _ctr;
  late String getTag;
  bool _isInitialised = false;

  final PlayVideoFrom playVideoFrom;
  final PodPlayerConfig podPlayerConfig;

  /// controller for pod player
  PodPlayerController({
    required this.playVideoFrom,
    this.podPlayerConfig = const PodPlayerConfig(),
  }) {
    getTag = UniqueKey().toString();
    Get.config(enableLog: PodVideoPlayer.enableLogs);
    _ctr = Get.put(PodGetXVideoController(), permanent: true, tag: getTag)
      ..config(
        playVideoFrom: playVideoFrom,
        playerConfig: podPlayerConfig,
      );
  }

  /// Initialsing video player
  Future<void> initialise() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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

  /// returns the urll of current playing video
  String? get videoUrl => _ctr.playingVideoUrl;

  /// returns true if video player is initialized
  bool get isInitialised => _ctr.videoCtr?.value.isInitialized ?? false;

  /// returns true if video is playing
  bool get isVideoPlaying => _ctr.videoCtr?.value.isPlaying ?? false;

  /// returns true if video is in bufferubg state
  bool get isVideoBuffering => _ctr.videoCtr?.value.isBuffering ?? false;

  /// retuens true if `loop` is enabled
  bool get isVideoLooping => _ctr.videoCtr?.value.isLooping ?? false;

  /// returns true if video is in fullscreen mode
  bool get isFullScreen => _ctr.isFullScreen;

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

  /// plays the video
  void play() => _ctr.podVideoStateChanger(PodVideoState.playing);

  /// pauses the video
  void pause() => _ctr.podVideoStateChanger(PodVideoState.paused);

  /// toogle play and pause
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

  /// mute the volume of the video
  Future<void> mute() async => _ctr.mute();

  /// unmutue the volume of the video
  Future<void> unMute() async => _ctr.unMute();

  /// toggle the volume
  Future<void> toggleVolume() async {
    _ctr.isMute ? await _ctr.unMute() : await _ctr.mute();
  }

  ///Dispose pod video player controller
  void dispose() {
    _ctr.videoCtr?.removeListener(_ctr.videoListner);
    _ctr.videoCtr?.dispose();
    _ctr.removeListenerId('podVideoState', _ctr.podStateListner);
    if (podPlayerConfig.wakelockEnabled) Wakelock.disable();
    Get.delete<PodGetXVideoController>(
      force: true,
      tag: getTag,
    );
  }

  /// used to change the video
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

  /// Enables video player to fullscreeen mode
  void enableFullScreen() {
    _html.document.documentElement?.requestFullscreen();
    _ctr.enableFullScreen(getTag);
  }

  /// Disables fullscreeen mode
  void disableFullScreen(BuildContext context) {
    _html.document.exitFullscreen();
    if (!_ctr.isWebPopupOverlayOpen) _ctr.disableFullScreen(context, getTag);
  }

  /// listner for the changes in the qualty of the video
  void onVideoQualityChanged(VoidCallback callback) {
    _ctr.onVimeoVideoQualityChanged = callback;
  }

  static Future<List<VideoQalityUrls>?> getYoutubeUrls(String youtubeIdOrUrl) {
    return VideoApis.getYoutubeVideoQualityUrls(youtubeIdOrUrl);
  }

  static Future<List<VideoQalityUrls>?> getVimeoUrls(String videoId) {
    return VideoApis.getVimeoVideoQualityUrls(videoId);
  }
// TODO(any): support for playlist
}
