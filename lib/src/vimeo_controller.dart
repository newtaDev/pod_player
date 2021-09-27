import 'package:fl_video_player/src/fl_enums.dart';
import 'package:fl_video_player/src/vimeo_models.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'vimeo_video_api.dart';

class FlVideoController extends GetxController {
  VideoPlayerController? controller;
  late FlVideoPlayerType videoPlayerType;
  FlVideoState flVideoState = FlVideoState.loading;
  late String initUrl;
  List<VimeoVideoQalityUrls>? vimeoVideoUrls;

  ///get all  `quality urls`
  Future<void> getVimeoVideoUrls({required String videoId}) async {
    try {
      flVideoStateChanger(FlVideoState.loading);
      vimeoVideoUrls = await VimeoVideoApi.getvideoQualityLink(videoId);
    } catch (e) {
      flVideoStateChanger(FlVideoState.error);

      rethrow;
    }
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(String quality) {
    return vimeoVideoUrls
        ?.firstWhere((element) => element.quality == quality)
        .urls;
  }

  ///check video player type
  void checkPlayerType({String? vimeoVideoId, String? videoUrl}) {
    if (vimeoVideoId != null) {
      videoPlayerType = FlVideoPlayerType.vimeo;
      return;
    } else {
      if (videoUrl == null) {
        throw Exception('videoUrl is required');
      }
      videoPlayerType = FlVideoPlayerType.general;
    }
  }

  ///config vimeo player
  Future<void> vimeoPlayerinit(String videoId) async {
    await getVimeoVideoUrls(videoId: videoId);
    initUrl = getQualityUrl(vimeoVideoUrls?.last.quality ?? '720p')!;
  }

  ///updates state with id `flVideoState`
  void flVideoStateChanger(FlVideoState _val) {
    flVideoState = _val;
    update(['flVideoState']);
  }
}
