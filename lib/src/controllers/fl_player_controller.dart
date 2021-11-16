part of 'fl_getx_video_controller.dart';

class _FlPlayerController extends FlBaseController {
  late AnimationController playPauseCtr;
  Timer? showOverlayTimer;
  Timer? showOverlayTimer1;

  bool isOverlayVisible = true;
  bool isLooping = false;
  bool isFullScreen = false;
  bool isvideoPlaying = false;

  List<String> videoPlaybackSpeeds = [
    '0.25x',
    '0.5x',
    '0.75x',
    'Normal',
    '1.25x',
    '1.5x',
    '1.75x',
    '2x',
  ];

  ///

  ///*seek video
  /// Seek video to a duration.
  Future<void> seekTo(Duration moment) async {
    await _videoCtr!.seekTo(moment);
  }

  /// Seek video forward by the duration.
  Future<void> seekForward(Duration videoSeekDuration) async {
    await seekTo(_videoCtr!.value.position + videoSeekDuration);
  }

  /// Seek video backward by the duration.
  Future<void> seekBackward(Duration videoSeekDuration) async {
    await seekTo(_videoCtr!.value.position - videoSeekDuration);
  }

  ///mute
  /// Toggle mute.
  Future<void> toggleMute() async {
    isMute = !isMute;
    if (isMute) {
      await mute();
    } else {
      await unMute();
    }
  }

  Future<void> mute() async {
    await setVolume(0);
    update(['volume']);
  }

  Future<void> unMute() async {
    await setVolume(1);
    update(['volume']);
  }

// Set volume between 0.0 - 1.0,
  /// 0.0 is mute and 1.0 max volume.
  Future<void> setVolume(
    double volume,
  ) async {
    await _videoCtr?.setVolume(volume);
    if (volume <= 0) {
      isMute = true;
    } else {
      isMute = false;
    }
    update(['volume']);
  }

  ///*controll play pause
  Future<void> playVideo(bool val) async {
    isvideoPlaying = val;
    if (isvideoPlaying) {
      isShowOverlay(true);
      // ignore: unawaited_futures
      _videoCtr?.play();
      await playPauseCtr.forward();
      isShowOverlay(false, delay: const Duration(seconds: 1));
    } else {
      isShowOverlay(true);
      // ignore: unawaited_futures
      _videoCtr?.pause();
      await playPauseCtr.reverse();
    }
  }

  ///toogle play pause
  void togglePlayPauseVideo() {
    isvideoPlaying = !isvideoPlaying;
    flVideoStateChanger(
        isvideoPlaying ? FlVideoState.playing : FlVideoState.paused);
  }

  ///toogle video player controls
  void isShowOverlay(bool val, {Duration? delay}) {
    showOverlayTimer1?.cancel();
    showOverlayTimer1 = Timer(delay ?? Duration.zero, () {
      if (isOverlayVisible != val) {
        isOverlayVisible = val;
        update(['overlay']);
      }
    });
  }

  ///overlay above video contrller
  void toggleVideoOverlay() {
    if (!isOverlayVisible) {
      isOverlayVisible = true;
      update(['overlay']);
      return;
    }
    if (isOverlayVisible) {
      isOverlayVisible = false;
      update(['overlay']);
      showOverlayTimer?.cancel();
      showOverlayTimer = Timer(const Duration(seconds: 4), () {
        if (isOverlayVisible) {
          isOverlayVisible = false;
          update(['overlay']);
        }
      });
    }
  }

  void setVideoPlayBack(String _speed) {
    late double pickedSpeed;

    if (_speed == 'Normal') {
      pickedSpeed = 1.0;
      _currentPaybackSpeed = 'Normal';
    } else {
      pickedSpeed = double.parse(_speed.split('x').first);
      _currentPaybackSpeed = _speed;
    }
    _videoCtr?.setPlaybackSpeed(pickedSpeed);
  }

  Future<void> setLooping(bool _isLooped) async {
    isLooping = _isLooped;
    await _videoCtr?.setLooping(isLooping);
  }

  Future<void> toggleLooping() async {
    isLooping = !isLooping;
    await _videoCtr?.setLooping(isLooping);
    update();
  }

  void enableFullScreen() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!isFullScreen) {
      isFullScreen = true;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        update(['full-screen']);
      });
    }
  }

  Future<void> disableFullScreen() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    if (isFullScreen) {
      isFullScreen = false;
      update(['full-screen']);
    }
  }

  void exitFullScreenView(BuildContext context) {
    Get.find<FlGetXVideoController>().disableFullScreen().then((value) {
      if (isWebPopupOverlayOpen) Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  void enableFullScreenView(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        pageBuilder: (BuildContext context, _, __) => const FullScreenView(),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  ///claculates video `position` or `duration`
  String calculateVideoDuration(Duration _duration) {
    final _totalHour = _duration.inHours == 0 ? '' : '${_duration.inHours}:';
    final _totalMinute = _duration.toString().split(':')[1];
    final _totalSeconds = (_duration - Duration(minutes: _duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    final String videoLength = '$_totalHour$_totalMinute:$_totalSeconds';
    return videoLength;
  }
}
