part of 'pod_getx_video_controller.dart';
// ignore_for_file: prefer_final_fields

class _PodBaseController extends GetxController {
  ///main video controller
  VideoPlayerController? _videoCtr;

  ///
  late PodVideoPlayerType _videoPlayerType;

  bool isMute = false;
  FocusNode? keyboardFocusWeb;

  bool autoPlay = true;
  bool _isWebAutoPlayDone = false;

  ///
  PodVideoState _podVideoState = PodVideoState.loading;

  ///
  bool isWebPopupOverlayOpen = false;

  ///
  Duration _videoDuration = Duration.zero;

  Duration _videoPosition = Duration.zero;

  String _currentPaybackSpeed = '1x';

  bool? isVideoUiBinded;

  bool? wasVideoPlayingOnUiDispose;

  int doubleTapForwardSeconds = 10;
  String? playingVideoUrl;

  late BuildContext mainContext;
  late BuildContext fullScreenContext;

  ///**listners

  Future<void> videoListner() async {
    if (!_videoCtr!.value.isInitialized) {
      await _videoCtr!.initialize();
    }
    if (_videoCtr!.value.isInitialized) {
      // _listneToVideoState();
      _listneToVideoPosition();
      _listneToVolume();
      if (kIsWeb && autoPlay && isMute && !_isWebAutoPlayDone) _webAutoPlay();
    }
  }

  void _webAutoPlay() => _videoCtr!.setVolume(1);

  void _listneToVolume() {
    if (_videoCtr!.value.volume == 0) {
      if (!isMute) {
        isMute = true;
        update(['volume']);
        update(['update-all']);
      }
    } else {
      if (isMute) {
        isMute = false;
        update(['volume']);
        update(['update-all']);
      }
    }
  }

  // void _listneToVideoState() {
  //   podVideoStateChanger(
  //     _videoCtr!.value.isBuffering || !_videoCtr!.value.isInitialized
  //         ? PodVideoState.loading
  //         : _videoCtr!.value.isPlaying
  //             ? PodVideoState.playing
  //             : PodVideoState.paused,
  //   );
  // }

  ///updates state with id `_podVideoState`
  void podVideoStateChanger(PodVideoState? _val, {bool updateUi = true}) {
    if (_podVideoState != (_val ?? _podVideoState)) {
      _podVideoState = _val ?? _podVideoState;
      if (updateUi) {
        update(['podVideoState']);
        update(['update-all']);
      }
    }
  }

  void _listneToVideoPosition() {
    if ((_videoCtr?.value.duration.inSeconds ?? Duration.zero.inSeconds) < 60) {
      _videoPosition = _videoCtr?.value.position ?? Duration.zero;
      update(['video-progress']);
      update(['update-all']);
    } else {
      if (_videoPosition.inSeconds !=
          (_videoCtr?.value.position ?? Duration.zero).inSeconds) {
        _videoPosition = _videoCtr?.value.position ?? Duration.zero;
        update(['video-progress']);
        update(['update-all']);
      }
    }
  }

  void keyboadListner() {
    if (keyboardFocusWeb != null && !keyboardFocusWeb!.hasFocus) {
      if (keyboardFocusWeb!.canRequestFocus) {
        keyboardFocusWeb!.requestFocus();
      }
    }
  }

  // void keyboadFullScreenListner() {
  //   print(keyboardFocusOnFullScreen?.hasFocus);
  //   if (keyboardFocusOnFullScreen != null &&
  //       !keyboardFocusOnFullScreen!.hasFocus) {
  //     if (keyboardFocusOnFullScreen!.canRequestFocus) {
  //       keyboardFocusOnFullScreen!.requestFocus();
  //     }
  //   }
  // }
}
