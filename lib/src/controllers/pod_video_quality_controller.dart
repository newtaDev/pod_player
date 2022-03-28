part of 'pod_getx_video_controller.dart';

class _PodVideoQualityController extends _PodVideoController {
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
  Future<void> getQualityUrlsFromVimeoId({
    String? videoId,
  }) async {
    try {
      podVideoStateChanger(PodVideoState.loading);
      final _vimeoVideoUrls = await VimeoVideoApi.getvideoQualityLink(videoId!);

      ///
      vimeoOrVideoUrls = _vimeoVideoUrls ?? [];
    } catch (e) {
      rethrow;
    }
  }

  void sortQualityVideoUrls(
    List<VideoQalityUrls>? urls,
  ) {
    final _urls = urls;

    ///has issues with 240p
    _urls?.removeWhere((element) => element.quality == 240);

    ///has issues with 144p
    if (kIsWeb) {
      _urls?.removeWhere((element) => element.quality == 144);
    }

    ///sort
    _urls?.sort((a, b) => a.quality.compareTo(b.quality));

    ///
    vimeoOrVideoUrls = _urls ?? [];
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(int quality) {
    return vimeoOrVideoUrls
        .firstWhere(
          (element) => element.quality == quality,
          orElse: () => vimeoOrVideoUrls.first,
        )
        .url;
  }

  ///config vimeo player
  Future<String> getVideoUrlFromVimeoId({
    String? videoId,
    int? quality,
  }) async {
    await getQualityUrlsFromVimeoId(videoId: videoId);
    sortQualityVideoUrls(vimeoOrVideoUrls);
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    final q = quality ?? vimeoOrVideoUrls[0].quality;
    _videoQualityUrl = getQualityUrl(q).toString();
    vimeoPlayingVideoQuality = q;
    return _videoQualityUrl;
  }

  Future<String> getUrlFromVideoQualityUrls({
    int? quality,
    required List<VideoQalityUrls> videoUrls,
  }) async {
    sortQualityVideoUrls(videoUrls);
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    final q = quality ?? vimeoOrVideoUrls[0].quality;
    _videoQualityUrl = getQualityUrl(q).toString();
    vimeoPlayingVideoQuality = q;
    return _videoQualityUrl;
  }

  Future<List<VideoQalityUrls>> getVideoQualityUrlsFromYoutube(
    String youtubeIdOrUrl,
  ) async {
    try {
      final yt = YoutubeExplode();
      final muxed =
          (await yt.videos.streamsClient.getManifest(youtubeIdOrUrl)).muxed;
      final _urls = muxed
          .map(
            (element) => VideoQalityUrls(
              quality: int.parse(element.qualityLabel.split('p')[0]),
              url: element.url.toString(),
            ),
          )
          .toList();

      // Close the YoutubeExplode's http client.
      yt.close();
      return _urls;
    } catch (error) {
      if (error.toString().contains('XMLHttpRequest')) {
        log(
          podErrorString(
            '(INFO) To play youtube video in WEB, Please enable CORS in your browser',
          ),
        );
      }
      debugPrint('===== YOUTUBE API ERROR: $error ==========');
      rethrow;
    }
  }

  Future<void> changeVideoQuality(int? quality) async {
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    if (vimeoPlayingVideoQuality != quality) {
      _videoQualityUrl = vimeoOrVideoUrls
          .where((element) => element.quality == quality)
          .first
          .url;
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
