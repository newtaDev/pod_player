import 'package:fl_video_player/fl_video_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromNetwork extends StatefulWidget {
  const PlayVideoFromNetwork({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromNetwork> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromNetwork> {
  late final FlVideoController controller;
  @override
  void initState() {
    controller = FlVideoController(
      playVideoFrom: PlayVideoFrom(
        fromNetworkUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      ),
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
      body:
          SafeArea(child: Center(child: FlVideoPlayer(controller: controller))),
    );
  }
}
