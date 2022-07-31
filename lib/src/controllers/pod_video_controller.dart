part of 'pod_getx_video_controller.dart';

class _PodVideoController extends _PodUiController {
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
    '1x',
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
    update(['update-all']);
  }

  Future<void> unMute() async {
    await setVolume(1);
    update(['volume']);
    update(['update-all']);
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
    update(['update-all']);
  }

  ///*controll play pause
  Future<void> playVideo(bool val) async {
    isvideoPlaying = val;
    if (isvideoPlaying) {
      isShowOverlay(true);
      // ignore: unawaited_futures
      _videoCtr?.play();
      isShowOverlay(false, delay: const Duration(seconds: 1));
    } else {
      isShowOverlay(true);
      // ignore: unawaited_futures
      _videoCtr?.pause();
    }
  }

  ///toogle play pause
  void togglePlayPauseVideo() {
    isvideoPlaying = !isvideoPlaying;
    podVideoStateChanger(
      isvideoPlaying ? PodVideoState.playing : PodVideoState.paused,
    );
  }

  ///toogle video player controls
  void isShowOverlay(bool val, {Duration? delay}) {
    showOverlayTimer1?.cancel();
    showOverlayTimer1 = Timer(delay ?? Duration.zero, () {
      if (isOverlayVisible != val) {
        isOverlayVisible = val;
        update(['overlay']);
        update(['update-all']);
      }
    });
  }

  ///overlay above video contrller
  void toggleVideoOverlay() {
    if (!isOverlayVisible) {
      isOverlayVisible = true;
      update(['overlay']);
      update(['update-all']);
      return;
    }
    if (isOverlayVisible) {
      isOverlayVisible = false;
      update(['overlay']);
      update(['update-all']);
      showOverlayTimer?.cancel();
      showOverlayTimer = Timer(const Duration(seconds: 3), () {
        if (isOverlayVisible) {
          isOverlayVisible = false;
          update(['overlay']);
          update(['update-all']);
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
    update(['update-all']);
  }

  Future<void> enableFullScreen(String tag) async {
    podLog('-full-screen-enable-entred');
    if (!isFullScreen) {
      if (onToggleFullScreen != null) {
        await onToggleFullScreen!(true);
      } else {
        await Future.wait([
          SystemChrome.setPreferredOrientations(
            [
              if (!kIsWeb) DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
          ),
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
        ]);
      }

      _enableFullScreenView(tag);
      isFullScreen = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        update(['full-screen']);
        update(['update-all']);
      });
    }
  }

  Future<void> disableFullScreen(
    BuildContext context,
    String tag, {
    bool enablePop = true,
  }) async {
    podLog('-full-screen-disable-entred');
    if (isFullScreen) {
      if (onToggleFullScreen != null) {
        await onToggleFullScreen!(false);
      } else {
        await Future.wait([
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]),
          SystemChrome.setPreferredOrientations(DeviceOrientation.values),
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          ),
        ]);
      }

      if (enablePop) _exitFullScreenView(context, tag);
      isFullScreen = false;
      update(['full-screen']);
      update(['update-all']);
    }
  }

  void _exitFullScreenView(BuildContext context, String tag) {
    podLog('popped-full-screen');
    Navigator.of(fullScreenContext).pop();
  }

  void _enableFullScreenView(String tag) {
    if (!isFullScreen) {
      podLog('full-screen-enabled');

      Navigator.push(
        mainContext,
        PageRouteBuilder(
          fullscreenDialog: true,
          pageBuilder: (BuildContext context, _, __) => FullScreenView(
            tag: tag,
          ),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    }
  }

  /// Calculates video `position` or `duration`
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
