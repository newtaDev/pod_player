import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromYoutube extends StatefulWidget {
  const PlayVideoFromYoutube({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromYoutube> createState() => _PlayVideoFromVimeoIdState();
}

class _PlayVideoFromVimeoIdState extends State<PlayVideoFromYoutube> {
  late final PodPlayerController controller;
  final videoTextFieldCtr = TextEditingController();
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube('https://youtu.be/A3ltMaM6noM'),
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
      appBar: AppBar(title: const Text('Youtube player')),
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              PodVideoPlayer(controller: controller),
              const SizedBox(height: 40),
              _loadVideoFromUrl()
            ],
          ),
        ),
      ),
    );
  }

  Row _loadVideoFromUrl() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: videoTextFieldCtr,
            decoration: const InputDecoration(
              labelText: 'Enter youtube url/id',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'https://youtu.be/A3ltMaM6noM',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FocusScope(
          canRequestFocus: false,
          child: ElevatedButton(
            onPressed: () async {
              if (videoTextFieldCtr.text.isEmpty) {
                snackBar('Please enter the url');
                return;
              }
              try {
                snackBar('Loading....');
                FocusScope.of(context).unfocus();
                await controller.changeVideo(
                  playVideoFrom: PlayVideoFrom.youtube(videoTextFieldCtr.text),
                );
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              } catch (e) {
                snackBar('Unable to load,\n $e');
              }
            },
            child: const Text('Load Video'),
          ),
        ),
      ],
    );
  }

  void snackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }
}
