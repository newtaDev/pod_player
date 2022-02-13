import 'package:fl_video_player/fl_video_player.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyHomePage2(
                      title: 'title',
                    ),
                  ),
                );
              },
              child: const Text('VideoPlayer')),
        ],
      ),
    );
  }
}

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage2> createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  late FlVideoController controller;
  @override
  void initState() {
    super.initState();
    controller = FlVideoController(
      // playerType: FlVideoPlayerType.asset,
      // fromAssets: 'assets/long_video.mkv',
      // fromAssets: 'assets/SampleVideo_720x480_20mb.mp4',
      fromNetworkUrl:
          // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      // 'https://user-images.githubusercontent.com/85326522/140480457-ab21345a-76e2-4b0e-b4ec-027c89f0e712.mp4',
      // 'http://techslides.com/demos/sample-videos/small.mp4',
      // fromVimeoVideoId: '518228118',
      // playerConfig : const FlVideoPlayerConfig(autoPlay: false,isLooping: true)
      playerConfig: const FlVideoPlayerConfig(forcedVideoFocus: true),
    )..initialise();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          children: [
            FlVideoPlayer(
              controller: controller,
            ),
            TextButton(onPressed: () {}, child: const Text('Haii')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // print(controller.currentVideoPosition);
            // print(controller.isInitialized);
            // print(controller.totalVideoLength);
            // controller.play();
            // controller.changeVideo(
            //   fromNetworkUrl:
            //       'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
            // );
            // print(controller.videoPlayerValue?.size);
            controller.unMute();
          },
        ));
  }
}
