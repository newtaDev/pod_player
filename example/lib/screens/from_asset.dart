import 'package:pod_player/fl_video_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromAsset extends StatefulWidget {
  const PlayVideoFromAsset({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromAsset> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromAsset> {
  late final FlVideoController controller;
  @override
  void initState() {
    controller = FlVideoController(
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
      body: Center(child: FlVideoPlayer(controller: controller)),
    );
  }
}
