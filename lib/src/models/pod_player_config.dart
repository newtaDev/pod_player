class PodPlayerConfig {
  final bool autoPlay;
  final bool isLooping;
  final bool forcedVideoFocus;
  final bool wakelockEnabled;
  const PodPlayerConfig({
    this.autoPlay = true,
    this.isLooping = false,
    this.forcedVideoFocus = false,
    this.wakelockEnabled = true,
  });

  PodPlayerConfig copyWith({
    bool? autoPlay,
    bool? isLooping,
    bool? forcedVideoFocus,
  }) {
    return PodPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      isLooping: isLooping ?? this.isLooping,
      forcedVideoFocus: forcedVideoFocus ?? this.forcedVideoFocus,
    );
  }
}
