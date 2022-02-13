part of 'fl_getx_video_controller.dart';
// ignore_for_file: prefer_final_fields

class FlBaseController extends GetxController {
  ///main video controller
  VideoPlayerController? _videoCtr;

  ///
  late FlVideoPlayerType _videoPlayerType;

  bool isMute = false;
  FocusNode? keyboardFocusWeb;

  bool autoPlay = true;
  bool _isWebAutoPlayDone = false;

  ///
  FlVideoState _flVideoState = FlVideoState.loading;

  ///
  bool isWebPopupOverlayOpen = false;

  ///
  Duration _videoDuration = Duration.zero;

  Duration _videoPosition = Duration.zero;

  String _currentPaybackSpeed = 'Normal';

  bool? isVideoUiBinded;

  bool? wasVideoPlayingOnUiDispose;

  ///**listners

  Future<void> videoListner() async {
    if (!_videoCtr!.value.isInitialized) {
      await _videoCtr!.initialize();
    }
    if (_videoCtr!.value.isInitialized) {
      _listneToVideoState();
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

  void _listneToVideoState() {
    flVideoStateChanger(
      _videoCtr!.value.isBuffering || !_videoCtr!.value.isInitialized
          ? FlVideoState.loading
          : _videoCtr!.value.isPlaying
              ? FlVideoState.playing
              : FlVideoState.paused,
    );
  }

  ///updates state with id `_flVideoState`
  void flVideoStateChanger(FlVideoState? _val) {
    if (_flVideoState != (_val ?? _flVideoState)) {
      _flVideoState = _val ?? _flVideoState;
      update(['flVideoState']);
      update(['update-all']);
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
