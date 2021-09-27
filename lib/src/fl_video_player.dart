import 'dart:developer';

import 'package:fl_video_player/src/vimeo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:video_player/video_player.dart';

import 'fl_enums.dart';
import 'vimeo_models.dart';
import 'vimeo_video_api.dart';

class FlVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final String? vimeoVideoId;
  const FlVideoPlayer({
    Key? key,
    this.videoUrl,
    this.vimeoVideoId,
  }) : super(key: key);

  @override
  _FlVideoPlayerState createState() => _FlVideoPlayerState();
}

class _FlVideoPlayerState extends State<FlVideoPlayer> {
  late FlVideoController _flCtr;

  @override
  void initState() {
    super.initState();
    _flCtr = Get.put(FlVideoController());
    _videoInit();
  }

  Future<void> _videoInit() async {
    _flCtr.checkPlayerType(
      videoUrl: widget.videoUrl,
      vimeoVideoId: widget.vimeoVideoId,
    );
    try {
      if (_flCtr.videoPlayerType == FlVideoPlayerType.vimeo) {
        await _flCtr.vimeoPlayerinit(widget.vimeoVideoId!);
      } else {
        _flCtr.initUrl = widget.videoUrl!;
      }
      _flCtr.controller = VideoPlayerController.network(_flCtr.initUrl);
      await _flCtr.controller?.initialize();
      setState(() {});
    } catch (e) {
      log('cathed $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    ///
    const circularProgressIndicator = CircularProgressIndicator(
      backgroundColor: Colors.black87,
      color: Colors.white,
      strokeWidth: 2,
    );
    return Center(
      child: ColoredBox(
        color: Colors.black,
        child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: _flCtr.controller == null
                  ? circularProgressIndicator
                  : _flCtr.controller!.value.isInitialized
                      ? _FlPlayer()
                      : circularProgressIndicator,
            )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _flCtr.controller?.dispose();
  }
}

class _FlPlayer extends StatelessWidget {
  const _FlPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlVideoController>();

    final overlayColor = Colors.black26;
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(_flCtr.controller!),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => log('message'),
                onDoubleTap: () {
                  print('Haiii');
                },
                child: ColoredBox(
                  color: overlayColor,
                  child: const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            GestureDetector(
                onTap: () => log('message'),
                child: ColoredBox(
                  color: overlayColor,
                  child: const SizedBox(
                    width: 200,
                    height: double.infinity,
                  ),
                )),
            Expanded(
              child: GestureDetector(
                onTap: () => log('message'),
                onDoubleTap: () {
                  print('Haiii');
                },
                child: ColoredBox(
                  color:overlayColor,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
