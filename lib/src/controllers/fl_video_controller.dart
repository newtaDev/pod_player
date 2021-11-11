import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../fl_video_player.dart';
import 'fl_getx_video_controller.dart';

class FlVideoController {
  late FlGetXVideoController _ctr;
  FlVideoController() {
    _ctr = Get.put(FlGetXVideoController(), permanent: true);
  }
  //!init
  Timer? initTimer;
  Future<void> initialize() async {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await _ctr.videoInit();
    });
    await _checkAndWaitTillInitialized();
  }

  Future<void> _checkAndWaitTillInitialized() async {
    if (_ctr.controllerInitialized) {
      return;
    } else {
      await Future.delayed(const Duration(seconds: 1));
      await _checkAndWaitTillInitialized();
    }
  }

  bool get isInitialized => _ctr.videoCtr?.value.isInitialized ?? false;

  // Future<void> initialize() async => _ctr.videoCtr?.initialize;

  //! video positions

  ///return total length of the video
  Duration get totalVideoLength => _ctr.videoDuration;

  ///return current position/duration of the video
  Duration get currentVideoPosition => _ctr.videoPosition;

  //! video play/pause

  void play() => _ctr.flVideoStateChanger(FlVideoState.playing);

  void pause() => _ctr.flVideoStateChanger(FlVideoState.paused);

  //! volume Controllers

  Future<void> mute() async => _ctr.mute;

  Future<void> unMute() async => _ctr.mute;
}
