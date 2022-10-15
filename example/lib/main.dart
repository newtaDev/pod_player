import 'package:example/screens/from_asset.dart';
import 'package:example/screens/from_network.dart';
import 'package:example/screens/from_network_urls.dart';
import 'package:example/screens/from_vimeo_private_id.dart';
import 'package:example/screens/from_youtube.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

import 'screens/cutom_video_controllers.dart';
import 'screens/from_vimeo_id.dart';

void main() {
  PodVideoPlayer.enableLogs = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/fromVimeoId': (context) => const PlayVideoFromVimeoId(),
        '/fromVimeoPrivateId': (context) => const PlayVideoFromVimeoPrivateId(),
        '/fromYoutube': (context) => const PlayVideoFromYoutube(),
        '/fromAsset': (context) => const PlayVideoFromAsset(),
        '/fromNetwork': (context) => const PlayVideoFromNetwork(),
        '/fromNetworkQualityUrls': (context) =>
            const PlayVideoFromNetworkQualityUrls(),
        '/customVideo': (context) => const CustomVideoControlls(),
      },
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            // _button('Play video from File'),
            _button(
              'Play video from Network',
              onPressed: () => Navigator.of(context).pushNamed('/fromNetwork'),
            ),
            _button(
              'Play video from Youtube',
              onPressed: () => Navigator.of(context).pushNamed('/fromYoutube'),
            ),
            _button(
              'Play video from Network quality urls',
              onPressed: () =>
                  Navigator.of(context).pushNamed('/fromNetworkQualityUrls'),
            ),
            _button(
              'Play video from Asset (with custom labels)',
              onPressed: () => Navigator.of(context).pushNamed('/fromAsset'),
            ),
            _button(
              'Play video from Vimeo',
              onPressed: () => Navigator.of(context).pushNamed('/fromVimeoId'),
            ),
            _button(
              'Play private video from Vimeo',
              onPressed: () =>
                  Navigator.of(context).pushNamed('/fromVimeoPrivateId'),
            ),
            _button(
              'Custom Video player',
              onPressed: () => Navigator.of(context).pushNamed('/customVideo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(String text, {void Function()? onPressed}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: OutlinedButton(
          onPressed: onPressed ?? () {},
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
