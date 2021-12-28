class FlVideoPlayerConfig {
  final bool autoPlay;
  final bool isLooping;
  final bool forcedVideoFocus;
  const FlVideoPlayerConfig({
    this.autoPlay = true,
    this.isLooping = false,
    this.forcedVideoFocus = false,
  });

  FlVideoPlayerConfig copyWith({
    bool? autoPlay,
    bool? isLooping,
    bool? forcedVideoFocus,
  }) {
    return FlVideoPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      isLooping: isLooping ?? this.isLooping,
      forcedVideoFocus: forcedVideoFocus ?? this.forcedVideoFocus,
    );
  }
}
