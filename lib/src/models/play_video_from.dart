import 'dart:io';

import '../../pod_player.dart';

class PlayVideoFrom {
  final String? dataSource;
  final List<VimeoVideoQalityUrls>? vimeoUrls;
  final FlVideoPlayerType playerType;
  final VideoFormat? formatHint;
  final String? package;
  final File? file;
  final Future<ClosedCaptionFile>? closedCaptionFile;
  final VideoPlayerOptions? videoPlayerOptions;
  final Map<String, String> httpHeaders;

  const PlayVideoFrom({
    this.dataSource,
    this.vimeoUrls,
    this.formatHint,
    this.package,
    this.file,
    this.closedCaptionFile,
    this.videoPlayerOptions,
    this.httpHeaders = const {},
    required this.playerType,
  });

  factory PlayVideoFrom.network(
    String dataSource, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom(
      playerType: FlVideoPlayerType.network,
      dataSource: dataSource,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }

  factory PlayVideoFrom.asset(
    String dataSource, {
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) {
    return PlayVideoFrom(
      playerType: FlVideoPlayerType.asset,
      dataSource: dataSource,
      package: package,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  factory PlayVideoFrom.file(
    File file, {
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) {
    return PlayVideoFrom(
      file: file,
      playerType: FlVideoPlayerType.file,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  factory PlayVideoFrom.vimeoId(
    String dataSource, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom(
      playerType: FlVideoPlayerType.vimeo,
      dataSource: dataSource,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }

  factory PlayVideoFrom.vimeoUrls({
    required List<VimeoVideoQalityUrls> vimeoUrls,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom(
      playerType: FlVideoPlayerType.vimeo,
      vimeoUrls: vimeoUrls,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }
}
