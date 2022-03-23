part of 'pod_getx_video_controller.dart';

class _FlVimeoVideoController extends _FlPlayerController {
  ///
  int? vimeoPlayingVideoQuality;

  ///vimeo all quality urls
  List<VimeoVideoQalityUrls>? vimeoVideoUrls;
  late String _vimeoVideoUrl;

  ///invokes callback from external controller
  VoidCallback? onVimeoVideoQualityChanged;

  ///*vimeo player configs
  ///
  ///get all  `quality urls`
  Future<void> getVimeoVideoUrls({
    String? videoId,
    List<VimeoVideoQalityUrls>? vimeoUrls,
  }) async {
    try {
      flVideoStateChanger(FlVideoState.loading);
      final _vimeoVideoUrls =
          vimeoUrls ?? await VimeoVideoApi.getvideoQualityLink(videoId!);

      ///has issues with 240p
      _vimeoVideoUrls?.removeWhere((element) => element.quality == 240);

      ///sort
      _vimeoVideoUrls?.sort((a, b) => a.quality.compareTo(b.quality));

      ///
      vimeoVideoUrls = _vimeoVideoUrls;
    } catch (e) {
      flVideoStateChanger(FlVideoState.error);

      rethrow;
    }
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(int quality) {
    return vimeoVideoUrls
        ?.firstWhere((element) => element.quality == quality)
        .urls;
  }

  ///config vimeo player
  Future<void> vimeoPlayerInit({
    String? videoId,
    int? quality,
    List<VimeoVideoQalityUrls>? vimeoUrls,
  }) async {
    if (vimeoUrls != null) {
      await getVimeoVideoUrls(vimeoUrls: vimeoUrls);
    } else {
      await getVimeoVideoUrls(videoId: videoId);
    }
    if (vimeoVideoUrls?.isEmpty ?? true) {
      throw Exception('vimeoVideoUrls cannot be empty');
    }
    final q = quality ?? vimeoVideoUrls?[0].quality ?? 720;
    _vimeoVideoUrl = getQualityUrl(q).toString();
    vimeoPlayingVideoQuality = q;
  }

  Future<void> changeVimeoVideoQuality(int? quality) async {
    if (vimeoPlayingVideoQuality != quality) {
      _vimeoVideoUrl = vimeoVideoUrls
              ?.where((element) => element.quality == quality)
              .first
              .urls ??
          _vimeoVideoUrl;
      flLog(_vimeoVideoUrl);
      vimeoPlayingVideoQuality = quality;
      _videoCtr?.removeListener(videoListner);
      flVideoStateChanger(FlVideoState.paused);
      flVideoStateChanger(FlVideoState.loading);
      _videoCtr = VideoPlayerController.network(_vimeoVideoUrl);
      await _videoCtr?.initialize();
      _videoCtr?.addListener(videoListner);
      await _videoCtr?.seekTo(_videoPosition);
      setVideoPlayBack(_currentPaybackSpeed);
      flVideoStateChanger(FlVideoState.playing);
      onVimeoVideoQualityChanged?.call();
      update();
      update(['update-all']);
    }
  }
}
