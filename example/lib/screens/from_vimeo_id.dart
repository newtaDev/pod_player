import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromVimeoId extends StatefulWidget {
  const PlayVideoFromVimeoId({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromVimeoId> createState() => _PlayVideoFromVimeoIdState();
}

class _PlayVideoFromVimeoIdState extends State<PlayVideoFromVimeoId> {
  late final PodPlayerController controller;
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeo('518228118'),
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
      body: SafeArea(
        child: Center(
          child: PodVideoPlayer(controller: controller),
        ),
      ),
    );
  }
}
