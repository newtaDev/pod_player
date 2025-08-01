class PodPlayerConfig {
  final bool autoPlay;
  final bool isLooping;
  final bool forcedVideoFocus;
  final bool wakelockEnabled;

  /// Initial video quality priority. The first available option will be used,
  /// from start to the end of this list. If all options informed are not
  /// available or if nothing is provided, 360p is used.
  ///
  /// Default value is [1080, 720, 360]
  final List<int> videoQualityPriority;

  const PodPlayerConfig({
    this.autoPlay = true,
    this.isLooping = false,
    this.forcedVideoFocus = false,
    this.wakelockEnabled = true,
    this.videoQualityPriority = const [1080, 720, 360],
  });

  PodPlayerConfig copyWith({
    bool? autoPlay,
    bool? isLooping,
    bool? forcedVideoFocus,
    bool? wakelockEnabled,
    List<int>? videoQualityPriority,
  }) {
    return PodPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      isLooping: isLooping ?? this.isLooping,
      forcedVideoFocus: forcedVideoFocus ?? this.forcedVideoFocus,
      wakelockEnabled: wakelockEnabled ?? this.wakelockEnabled,
      videoQualityPriority: videoQualityPriority ?? this.videoQualityPriority,
    );
  }
}
