class PodPlayerLabels {
  final String play;
  final String pause;
  final String mute;
  final String unmute;
  final String settings;
  final String fullscreen;
  final String exitFullScreen;
  final String loopVideo;
  final String playbackSpeed;
  final String quality;
  final String optionEnabled;
  final String optionDisabled;
  final String error;

  /// Labels displayed in the video player progress bar and when an error occurs
  const PodPlayerLabels({
    this.play = 'Play',
    this.pause = 'Pause',
    this.mute = 'Mute',
    this.unmute = 'Unmute',
    this.settings = 'Settings',
    this.fullscreen = 'Fullscreen',
    this.exitFullScreen = 'Exit full screen',
    this.loopVideo = 'Loop Video',
    this.playbackSpeed = 'Playback speed',
    this.error = 'Error while playing video',
    this.quality = 'Quality',
    this.optionEnabled = 'on',
    this.optionDisabled = 'off',
  });
}
