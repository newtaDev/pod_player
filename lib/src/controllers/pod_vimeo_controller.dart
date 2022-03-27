part of 'pod_getx_video_controller.dart';

class _PodVimeoVideoController extends _PodVideoController {
  ///
  int? vimeoPlayingVideoQuality;

  ///vimeo all quality urls
  List<VideoQalityUrls> vimeoOrVideoUrls = [];
  late String _videoQualityUrl;

  ///invokes callback from external controller
  VoidCallback? onVimeoVideoQualityChanged;

  ///*vimeo player configs
  ///
  ///get all  `quality urls`
  Future<void> getVimeoVideoUrls({
    String? videoId,
    List<VideoQalityUrls>? vimeoUrls,
  }) async {
    try {
      podVideoStateChanger(PodVideoState.loading);
      final _vimeoVideoUrls =
          vimeoUrls ?? await VimeoVideoApi.getvideoQualityLink(videoId!);

      ///has issues with 240p
      _vimeoVideoUrls?.removeWhere((element) => element.quality == 240);

      ///sort
      _vimeoVideoUrls?.sort((a, b) => a.quality.compareTo(b.quality));

      ///
      vimeoOrVideoUrls = _vimeoVideoUrls ?? [];
    } catch (e) {
      podVideoStateChanger(PodVideoState.error);

      rethrow;
    }
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(int quality) {
    return vimeoOrVideoUrls
        .firstWhere((element) => element.quality == quality)
        .urls;
  }

  ///config vimeo player
  Future<String> vimeoPlayerInit({
    String? videoId,
    int? quality,
  }) async {
    await getVimeoVideoUrls(videoId: videoId);
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    final q = quality ?? vimeoOrVideoUrls[0].quality;
    _videoQualityUrl = getQualityUrl(q).toString();
    vimeoPlayingVideoQuality = q;
    return _videoQualityUrl;
  }

  Future<String> videoQualitysInit({
    int? quality,
    required List<VideoQalityUrls> videoUrls,
  }) async {
    await getVimeoVideoUrls(vimeoUrls: videoUrls);
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    final q = quality ?? vimeoOrVideoUrls[0].quality;
    _videoQualityUrl = getQualityUrl(q).toString();
    vimeoPlayingVideoQuality = q;
    return _videoQualityUrl;
  }

  Future<void> changeVideoQuality(int? quality) async {
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    if (vimeoPlayingVideoQuality != quality) {
      _videoQualityUrl = vimeoOrVideoUrls
          .where((element) => element.quality == quality)
          .first
          .urls;
      podLog(_videoQualityUrl);
      vimeoPlayingVideoQuality = quality;
      _videoCtr?.removeListener(videoListner);
      podVideoStateChanger(PodVideoState.paused);
      podVideoStateChanger(PodVideoState.loading);
      _videoCtr = VideoPlayerController.network(_videoQualityUrl);
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      _videoCtr?.addListener(videoListner);
      await _videoCtr?.seekTo(_videoPosition);
      setVideoPlayBack(_currentPaybackSpeed);
      podVideoStateChanger(PodVideoState.playing);
      onVimeoVideoQualityChanged?.call();
      update();
      update(['update-all']);
    }
  }
}
