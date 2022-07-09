import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromAsset extends StatefulWidget {
  const PlayVideoFromAsset({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromAsset> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromAsset> {
  late final PodPlayerController controller;
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.asset('assets/SampleVideo_720x480_20mb.mp4'),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play video from Asset (with custom labels)'),
      ),
      body: Center(
        child: PodVideoPlayer(
          controller: controller,
          podPlayerLabels: const PodPlayerLabels(
            play: "PLAY",
            pause: "PAUSE",
            error: "ERROR WHILE TRYING TO PLAY VIDEO",
            exitFullScreen: "EXIT FULL SCREEN",
            fullscreen: "FULL SCREEN",
            loopVideo: "LOOP VIDEO",
            mute: "MUTE",
            playbackSpeed: "PLAYBACK SPEED",
            settings: "SETTINGS",
            unmute: "UNMUTE",
            optionEnabled: "YES",
            optionDisabled: "NO",
            quality: "QUALITY",
          ),
        ),
      ),
    );
  }
}
