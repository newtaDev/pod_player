import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../fl_video_player.dart';
import '../controllers/fl_getx_video_controller.dart';
import '../utils/fl_enums.dart';

class FullScreenView extends StatefulWidget {
  final String tag;
  const FullScreenView({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView>
    with SingleTickerProviderStateMixin {
  late FlGetXVideoController _flCtr;
  @override
  void initState() {
    _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);
    _flCtr
      ..enableFullScreen()
      ..playPauseCtr = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
    if (_flCtr.isvideoPlaying) {
      _flCtr.playPauseCtr.forward();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const circularProgressIndicator = CircularProgressIndicator(
      backgroundColor: Colors.black87,
      color: Colors.white,
      strokeWidth: 2,
    );
    return WillPopScope(
      onWillPop: () async {
        await _flCtr.disableFullScreen();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GetBuilder<FlGetXVideoController>(
          tag: widget.tag,
          builder: (_flCtr) => Center(
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: _flCtr.videoCtr == null
                      ? circularProgressIndicator
                      : _flCtr.videoCtr!.value.isInitialized
                          ? FlPlayer(
                              tag: widget.tag,
                              videoPlayerCtr: _flCtr.videoCtr!,
                              aspectRatio:
                                  _flCtr.videoCtr?.value.aspectRatio ?? 16 / 9,
                            )
                          : circularProgressIndicator,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
