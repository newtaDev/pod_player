class PodPlayerConfig {
  final bool autoPlay;
  final bool isLooping;
  final bool forcedVideoFocus;
  final bool wakelockEnabled;
  final int? initialVideoQuality;
  const PodPlayerConfig({
    this.autoPlay = true,
    this.isLooping = false,
    this.forcedVideoFocus = false,
    this.wakelockEnabled = true,
    this.initialVideoQuality,
  });

  PodPlayerConfig copyWith({
    bool? autoPlay,
    bool? isLooping,
    bool? forcedVideoFocus,
    bool? wakelockEnabled,
    int? initialVideoQuality,
  }) {
    return PodPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      isLooping: isLooping ?? this.isLooping,
      forcedVideoFocus: forcedVideoFocus ?? this.forcedVideoFocus,
      wakelockEnabled: wakelockEnabled ?? this.wakelockEnabled,
      initialVideoQuality: initialVideoQuality ?? this.initialVideoQuality,
    );
  }
}
