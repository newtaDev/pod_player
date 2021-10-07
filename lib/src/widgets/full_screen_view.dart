import 'package:fl_video_player/fl_video_player.dart';
import 'package:fl_video_player/src/fl_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../fl_video_controller.dart';

class FullScreenView extends StatefulWidget {
  const FullScreenView({
    Key? key,
  }) : super(key: key);

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  final _flCtr = Get.find<FlVideoController>();
  @override
  void initState() {
    _flCtr.enableFullScreen();
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
        body: GetBuilder<FlVideoController>(
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
                          ? const FlPlayer()
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
