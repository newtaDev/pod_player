import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:fl_video_player/src/utils/vimeo_models.dart';

import '../../fl_video_player.dart';
import 'fl_getx_video_controller.dart';

class FlVideoController {
  ///
  late FlGetXVideoController _ctr;
  late String getTag;

  ///
  final FlVideoPlayerType playerType;
  final String? fromNetworkUrl;
  final String? fromVimeoVideoId;
  final List<VimeoVideoQalityUrls>? fromVimeoUrls;
  final String? fromAssets;
  final File? fromFile;
  final bool autoPlay;
  final bool isLooping;

  ///only for web
  final bool fourcedVideoFocus;
  FlVideoController({
    this.playerType = FlVideoPlayerType.auto,
    this.fromNetworkUrl,
    this.fromVimeoVideoId,
    this.fromVimeoUrls,
    this.fromAssets,
    this.fromFile,
    this.autoPlay = true,
    this.isLooping = false,
    this.fourcedVideoFocus = false,
  }) {
    getTag = UniqueKey().toString();
    _ctr = Get.put(FlGetXVideoController(), permanent: true, tag: getTag)
      ..config(
        playerType: playerType,
        fromNetworkUrl: fromNetworkUrl,
        fromVimeoVideoId: fromVimeoVideoId,
        fromVimeoUrls: fromVimeoUrls,
        fromAssets: fromAssets,
        fromFile: fromFile,
        isLooping: isLooping,
        autoPlay: autoPlay,
      );
  }
  //!init
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

  void dispose() {
    _ctr.videoCtr?.removeListener(_ctr.videoListner);
    _ctr.videoCtr?.dispose();
    _ctr.removeListenerId('flVideoState', _ctr.flStateListner);
    Get.delete<FlGetXVideoController>(
      force: true,
      tag: getTag,
    );
  }
}
