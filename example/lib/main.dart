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
      body: FlVideoPlayer(
        // playerType: FlVideoPlayerType.asset,
        fromAssets: 'assets/SampleVideo_720x480_20mb.mp4',
        // fromNetworkUrl:
        //     'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            // 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
            //'http://techslides.com/demos/sample-videos/small.mp4',
        // fromVimeoVideoId: '518228118',
        isLooping: true,
        autoPlay: false,
      ),
  
    );
  }
}
