part of 'fl_getx_video_controller.dart';

class FlBaseController extends GetxController {
  ///main video controller
  VideoPlayerController? _videoCtr;

  ///
  late FlVideoPlayerType _videoPlayerType;

  bool isMute = false;

  ///
  FlVideoState _flVideoState = FlVideoState.loading;

  ///
  bool isWebPopupOverlayOpen = false;

  ///
  Duration _videoDuration = Duration.zero;

  Duration _videoPosition = Duration.zero;

  String _currentPaybackSpeed = 'Normal';

  ///**listners

  Future<void> videoListner() async {
    if (!_videoCtr!.value.isInitialized) {
      await _videoCtr!.initialize();
    }
    if (_videoCtr!.value.isInitialized) {
      _listneToVideoState();
      _listneToVideoPosition();
      _listneToVolume();
    }
  }

  void _listneToVolume() {
    if (_videoCtr!.value.volume == 0) {
      if (!isMute) {
        isMute = true;
        update(['volume']);
      }
    } else {
      if (isMute) {
        isMute = false;
        update(['volume']);
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
    }
  }

  void _listneToVideoPosition() {
    if ((_videoCtr?.value.duration.inSeconds ?? Duration.zero.inSeconds) < 60) {
      _videoPosition = _videoCtr?.value.position ?? Duration.zero;
      update(['video-progress']);
    } else {
      if (_videoPosition.inSeconds !=
          (_videoCtr?.value.position ?? Duration.zero).inSeconds) {
        _videoPosition = _videoCtr?.value.position ?? Duration.zero;
        update(['video-progress']);
      }
    }
  }
}
