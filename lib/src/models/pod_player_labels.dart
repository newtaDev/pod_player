class PodPlayerLabels {
  final String? play;
  final String? pause;
  final String? mute;
  final String? unmute;
  final String settings;
  final String? fullscreen;
  final String? exitFullScreen;
  final String loopVideo;
  final String playbackSpeed;
  final String quality;
  final String optionEnabled;
  final String optionDisabled;
  final String error;

  /// Labels displayed in the video player progress bar and when an error occurs
  const PodPlayerLabels({
    this.play,
    this.pause,
    this.mute,
    this.unmute,
    this.settings = 'Settings',
    this.fullscreen,
    this.exitFullScreen,
    this.loopVideo = 'Loop Video',
    this.playbackSpeed = 'Playback speed',
    this.error = 'Error while playing video',
    this.quality = 'Quality',
    this.optionEnabled = 'on',
    this.optionDisabled = 'off',
  });
}
