import 'dart:developer';

import 'package:pod_player/pod_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomVideoControlls extends StatefulWidget {
  const CustomVideoControlls({Key? key}) : super(key: key);

  @override
  State<CustomVideoControlls> createState() => _CustomVideoControllsState();
}

class _CustomVideoControllsState extends State<CustomVideoControlls> {
  late PodPlayerController controller;
  bool? isVideoPlaying;
  final videoTextFieldCtr = TextEditingController(
    text:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  );
  final vimeoTextFieldCtr = TextEditingController(
    text: '518228118',
  );
  final youtubeTextFieldCtr = TextEditingController(
    text: 'https://youtu.be/A3ltMaM6noM',
  );

  bool alwaysShowProgressBar = true;
  @override
  void initState() {
    super.initState();
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.asset('assets/SampleVideo_720x480_20mb.mp4'),
      // fromAssets: 'assets/long_video.mkv',
      // fromAssets: 'assets/SampleVideo_720x480_20mb.mp4',
      // fromNetworkUrl:
      // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      // 'https://user-images.githubusercontent.com/85326522/140480457-ab21345a-76e2-4b0e-b4ec-027c89f0e712.mp4',
      // 'http://techslides.com/demos/sample-videos/small.mp4',
      // fromVimeoVideoId: '518228118',
    )..initialise().then((value) {
        setState(() {
          isVideoPlaying = controller.isVideoPlaying;
        });
      });
    controller.addListener(_listner);
  }

  ///Listnes to changes in video
  void _listner() {
    if (controller.isVideoPlaying != isVideoPlaying) {
      isVideoPlaying = controller.isVideoPlaying;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_listner);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///
    const sizeH20 = SizedBox(height: 20);
    final totalHour = controller.currentVideoPosition.inHours == 0
        ? '0'
        : '${controller.currentVideoPosition.inHours}:';
    final totalMinute =
        controller.currentVideoPosition.toString().split(':')[1];
    final totalSeconds = (controller.currentVideoPosition -
            Duration(minutes: controller.currentVideoPosition.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');

    ///
    const videoTitle = Padding(
      padding: kIsWeb
          ? EdgeInsets.symmetric(vertical: 25, horizontal: 15)
          : EdgeInsets.only(left: 15),
      child: Text(
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Player')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              sizeH20,
              PodVideoPlayer(
                alwaysShowProgressBar: alwaysShowProgressBar,
                controller: controller,
                matchFrameAspectRatioToVideo: true,
                matchVideoAspectRatioToFrame: true,
                videoTitle: videoTitle,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text('Video url : '),
                    Expanded(
                      child: Text(
                        controller.videoUrl ?? '',
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Video state: ${controller.videoState.name}',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    sizeH20,
                    Text(
                      '$totalHour hour: '
                      '$totalMinute minute: '
                      '$totalSeconds seconds',
                      style: textStyle,
                    ),
                    sizeH20,
                    _loadVideoFromUrl(),
                    sizeH20,
                    _loadVideoFromVimeo(),
                    sizeH20,
                    _loadVideoFromYoutube(),
                    sizeH20,
                    _iconButton('Hide progress bar on overlay hidden',
                        Icons.hide_source, onPressed: () {
                      setState(() {
                        alwaysShowProgressBar = false;
                      });
                    }),
                    sizeH20,
                    _iconButton('Show Overlay', Icons.slideshow_outlined,
                        onPressed: () {
                      controller.showOverlay();
                    }),
                    sizeH20,
                    _iconButton('Hide Overlay', Icons.hide_image,
                        onPressed: () {
                      controller.hideOverlay();
                    }),
                    _iconButton('Backward video 5s', Icons.replay_5_rounded,
                        onPressed: () {
                      controller.doubleTapVideoBackward(5);
                    }),
                    sizeH20,
                    _iconButton('Forward video 5s', Icons.forward_5_rounded,
                        onPressed: () {
                      controller.doubleTapVideoForward(5);
                    }),
                    sizeH20,
                    _iconButton('Video Jump to 01:00 minute',
                        Icons.fast_forward_rounded, onPressed: () {
                      controller.videoSeekTo(const Duration(minutes: 1));
                    }),
                    sizeH20,
                    _iconButton('Enable full screen', Icons.fullscreen,
                        onPressed: () {
                      controller.enableFullScreen();
                    }),
                    sizeH20,
                    _iconButton(
                        controller.isMute ? 'UnMute video' : 'mute video',
                        controller.isMute ? Icons.volume_up : Icons.volume_off,
                        onPressed: () {
                      controller.toggleVolume();
                    }),
                    sizeH20,
                    sizeH20,
                    Text(
                      'Is video initialized: ${controller.isInitialised}\n'
                      'Is video playing: ${controller.isVideoPlaying}\n'
                      'Is video Buffering: ${controller.isVideoBuffering}\n'
                      'Is video looping: ${controller.isVideoLooping}\n'
                      'Is video in fullscreeen: ${controller.isFullScreen}',
                      style: textStyle,
                    ),
                    sizeH20,
                    Text(
                      'Total Video length: ${controller.totalVideoLength}',
                      style: textStyle,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => controller.togglePlayPause(),
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
      ),
    );
  }

  Row _loadVideoFromVimeo() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: vimeoTextFieldCtr,
            decoration: const InputDecoration(
              labelText: 'Enter vimeo id',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            if (vimeoTextFieldCtr.text.isEmpty) {
              snackBar('Please enter vimeo id');
              return;
            }
            try {
              snackBar('Loading....');
              FocusScope.of(context).unfocus();
              await controller.changeVideo(
                playVideoFrom: PlayVideoFrom.vimeo(vimeoTextFieldCtr.text),
              );
              controller.addListener(_listner);
              controller.onVideoQualityChanged(
                () {
                  log('Vimeo video quality changed');
                  controller.addListener(_listner);
                },
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {
              snackBar(
                  "Unable to load,${kIsWeb ? 'Please enable CORS in web' : ''}  \n$e");
            }
          },
          child: const Text('Load Video'),
        ),
      ],
    );
  }

  Row _loadVideoFromYoutube() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: youtubeTextFieldCtr,
            decoration: const InputDecoration(
              labelText: 'Enter Youtube id/url',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            if (youtubeTextFieldCtr.text.isEmpty) {
              snackBar('Please enter vimeo id');
              return;
            }
            try {
              snackBar('Loading....');
              FocusScope.of(context).unfocus();
              await controller.changeVideo(
                playVideoFrom: PlayVideoFrom.youtube(youtubeTextFieldCtr.text),
              );
              controller.addListener(_listner);
              controller.onVideoQualityChanged(
                () {
                  log('Youtube video quality changed');
                  controller.addListener(_listner);
                },
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {
              snackBar(
                  "Unable to load,${kIsWeb ? 'Please enable CORS in web' : ''}  \n$e");
            }
          },
          child: const Text('Load Video'),
        ),
      ],
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
              labelText: 'Enter video url',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            if (videoTextFieldCtr.text.isEmpty) {
              snackBar('Please enter the url');
              return;
            }
            try {
              snackBar('Loading....');
              FocusScope.of(context).unfocus();
              await controller.changeVideo(
                playVideoFrom: PlayVideoFrom.network(videoTextFieldCtr.text),
              );
              controller.addListener(_listner);
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {
              snackBar('Unable to load,\n $e');
            }
          },
          child: const Text('Load Video'),
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

  ElevatedButton _iconButton(String text, IconData icon,
      {void Function()? onPressed}) {
    return ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
            fixedSize: const Size.fromWidth(double.maxFinite)),
        icon: Icon(icon),
        label: Text(text));
  }
}
