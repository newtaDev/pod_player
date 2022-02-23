import 'dart:io';

import '../../fl_video_player.dart';

class PlayVideoFrom {
  final FlVideoPlayerType playerType;
  final String? fromNetworkUrl;
  final String? fromVimeoVideoId;
  final List<VimeoVideoQalityUrls>? fromVimeoUrls;
  final String? fromAssets;
  final File? fromFile;
  PlayVideoFrom({
    this.playerType = FlVideoPlayerType.auto,
    this.fromNetworkUrl,
    this.fromVimeoVideoId,
    this.fromVimeoUrls,
    this.fromAssets,
    this.fromFile,
  });
}
