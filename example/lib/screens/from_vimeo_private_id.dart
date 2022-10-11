import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromVimeoPrivateId extends StatefulWidget {
  const PlayVideoFromVimeoPrivateId({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromVimeoPrivateId> createState() =>
      _PlayVideoFromVimeoPrivateIdState();
}

class _PlayVideoFromVimeoPrivateIdState
    extends State<PlayVideoFromVimeoPrivateId> {
  late final PodPlayerController controller;
  final videoTextFieldCtr = TextEditingController();
  final tokenTextFieldCtr = TextEditingController();

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
      appBar: AppBar(title: const Text('Vimeo Player')),
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
              labelText: 'Enter vimeo private id',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'ex: 518228118',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: tokenTextFieldCtr,
            decoration: const InputDecoration(
              labelText: 'Enter vimeo access token',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'ex: {32chars}',
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
                snackBar('Please enter the id');
                return;
              }
              if (tokenTextFieldCtr.text.isEmpty) {
                snackBar('Please enter the access token');
                return;
              }
              try {
                snackBar('Loading....');
                FocusScope.of(context).unfocus();

                final Map<String, String> headers = <String, String>{};
                headers['Authorization'] = 'Bearer ${tokenTextFieldCtr.text}';

                await controller.changeVideo(
                  playVideoFrom: PlayVideoFrom.vimeoPrivateVideos(
                    videoTextFieldCtr.text,
                    httpHeaders: headers,
                  ),
                );
                if (!mounted) return;
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
