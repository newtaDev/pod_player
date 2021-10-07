part of './fl_video_controller.dart';

class _FlPlayerController extends FlBaseController {
  late AnimationController playPauseCtr;
  Timer? showOverlayTimer;

  bool overlayVisible = true;
  bool autoPlay = true;
  bool isLooping = false;
  bool isFullScreen = false;

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
  bool _isvideoPlaying = false;

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

  ///*controll play pause
  Future<void> playVideo(bool val) async {
    _isvideoPlaying = val;
    if (_isvideoPlaying) {
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
    _isvideoPlaying = !_isvideoPlaying;
    flVideoStateChanger(
        _isvideoPlaying ? FlVideoState.playing : FlVideoState.paused);
  }

  ///toogle video player controls
  void isShowOverlay(bool val, {Duration? delay}) {
    showOverlayTimer?.cancel();
    showOverlayTimer = Timer(delay ?? Duration.zero, () {
      overlayVisible = val;
      update(['overlay']);
      showOverlayTimer?.cancel();
    });
  }

  ///overlay above video contrller
  Future<void> toggleVideoOverlay() async {
    if (!overlayVisible) {
      overlayVisible = true;
    } else {
      overlayVisible = false;
    }
    update(['overlay']);

    if (overlayVisible) {
      showOverlayTimer?.cancel();
      showOverlayTimer = Timer(const Duration(seconds: 4), () {
        if (overlayVisible) overlayVisible = false;
        update(['overlay']);
        showOverlayTimer?.cancel();
      });
      return;
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
  }

  void enableFullScreen() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    isFullScreen = true;
  }

  Future<void> disableFullScreen() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    isFullScreen = false;
  }

  ///claculates video `position` or `duration`
  String calculateVideoDuration(Duration _duration) {
    final _totalHour = _duration.inHours == 0 ? '' : '${_duration.inHours}:';
    final _totalMinute = _duration.inMinutes.toString();
    final _totalSeconds = (_duration - Duration(minutes: _duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    final String videoLength = '$_totalHour$_totalMinute:$_totalSeconds';
    return videoLength;
  }
}
