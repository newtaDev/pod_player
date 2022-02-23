import 'dart:html';

import 'package:fl_video_player/fl_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({Key? key}) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late FlVideoController controller;
  bool? isVideoPlaying;
  @override
  void initState() {
    super.initState();
    controller = FlVideoController(
      playVideoFrom: PlayVideoFrom(
        // playerType: FlVideoPlayerType.asset,
        // fromAssets: 'assets/long_video.mkv',
        fromAssets: 'assets/SampleVideo_720x480_20mb.mp4',
        // fromNetworkUrl:
        // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        // 'https://user-images.githubusercontent.com/85326522/140480457-ab21345a-76e2-4b0e-b4ec-027c89f0e712.mp4',
        // 'http://techslides.com/demos/sample-videos/small.mp4',
        // fromVimeoVideoId: '518228118',
      ),
      // playerConfig : const FlVideoPlayerConfig(autoPlay: false,isLooping: true)
      playerConfig: const FlVideoPlayerConfig(forcedVideoFocus: true),
      enableLogs: true,
    )..initialise().then((value) {
        setState(() {
          isVideoPlaying = controller.isVideoPlaying;
        });
      });
    controller.addListener(_listner);
  }

  void _listner() {
    if (controller.isVideoPlaying != isVideoPlaying) {
      setState(() {
        isVideoPlaying = controller.isVideoPlaying;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_listner);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlVideoPlayer(controller: controller),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              child: isVideoPlaying == null
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                        color: Colors.white,
                        strokeWidth: 1,
                      ),
                    )
                  : Icon(!isVideoPlaying! ? Icons.play_arrow : Icons.pause),
              backgroundColor: Colors.black,
              onPressed: () async {
                // print(controller.currentVideoPosition);
                // print(controller.isInitialized);
                // print(controller.totalVideoLength);
                // controller.play();
                controller.togglePlayPause();

                // print(controller.videoPlayerValue?.size);
                // controller.unMute();
              },
            ),
            FloatingActionButton.extended(
              heroTag: 'change-video',
              isExtended: true,
              label: Row(
                children: const [Icon(Icons.skip_next), Text('Change video')],
              ),
              backgroundColor: Colors.black,
              onPressed: () async {
                // print(controller.currentVideoPosition);
                // print(controller.isInitialized);
                // print(controller.totalVideoLength);
                // controller.play();
                await controller.changeVideo(
                    playVideoFrom: PlayVideoFrom(
                  fromNetworkUrl:
                      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                ));
                controller.addListener(_listner);

                // print(controller.videoPlayerValue?.size);
                // controller.unMute();
              },
            ),
          ],
        ));
  }
}
