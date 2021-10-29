part of './fl_video_controller.dart';

class FlBaseController extends GetxController {
  ///main video controller
  VideoPlayerController? _videoCtr;

  ///
  late FlVideoPlayerType _videoPlayerType;

  ///
  CustomOverlay? playBackOverlay;
  CustomOverlay? vimeoQualityOverlay;
  CustomOverlay? settingsOverlay;

  ///
  FlVideoState _flVideoState = FlVideoState.loading;

  ///
  Duration _videoDuration = Duration.zero;

  Duration _videoPosition = Duration.zero;

  late String _playingVideoUrl;

  String _currentPaybackSpeed = 'Normal';

  ///**listners

  Future<void> videoListner() async {
    if (!_videoCtr!.value.isInitialized) {
      await _videoCtr!.initialize();
    }
    if (_videoCtr!.value.isInitialized) {
      _listneVideoState();
      updateVideoPosition();
    }
  }

  void _listneVideoState() {
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

  void updateVideoPosition() {
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

  void closeCustomOverlays() {
    try {
      vimeoQualityOverlay?.close();
      playBackOverlay?.close();
      settingsOverlay?.close();
      playBackOverlay = null;
      vimeoQualityOverlay = null;
      settingsOverlay = null;
    } catch (e) {
      log('exception on closing overlay');
    }
  }
}
