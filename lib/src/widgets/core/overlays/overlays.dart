part of 'package:fl_video_player/src/fl_video_player.dart';

class _VideoOverlays extends StatelessWidget {
  final String tag;
  const _VideoOverlays({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    if (_flCtr.overlayBuilder != null) {
      return GetBuilder<FlGetXVideoController>(
        id: 'update-all',
        tag: tag,
        builder: (_flCtr) {
          ///Custom overlay
          final _progressBar = FlVideoProgressBar(
            tag: tag,
            flProgressBarConfig: _flCtr.flProgressBarConfig,
          );
          final overlayOptions = OverLayOptions(
            flVideoState: _flCtr.flVideoState,
            videoDuration: _flCtr.videoDuration,
            videoPosition: _flCtr.videoPosition,
            isFullScreen: _flCtr.isFullScreen,
            isLooping: _flCtr.isLooping,
            isOverlayVisible: _flCtr.isOverlayVisible,
            isMute: _flCtr.isMute,
            autoPlay: _flCtr.autoPlay,
            currentVideoPlaybackSpeed: _flCtr.currentPaybackSpeed,
            videoPlayBackSpeeds: _flCtr.videoPlaybackSpeeds,
            videoPlayerType: _flCtr.videoPlayerType,
            flProgresssBar: _progressBar,
          );
          return Stack(
            children: [
              Positioned.fill(
                child: _VideoGestureDetector(
                  tag: tag,
                  onTap: _flCtr.togglePlayPauseVideo,
                  onDoubleTap: () => _flCtr.toggleFullScreenOnWeb(context, tag),
                  child: const ColoredBox(
                    color: Colors.black38,
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              _flCtr.overlayBuilder?.call(overlayOptions) ?? const SizedBox(),
            ],
          );
        },
      );
    } else {
      ///Built in overlay
      return GetBuilder<FlGetXVideoController>(
        tag: tag,
        id: 'overlay',
        builder: (_flCtr) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _flCtr.isOverlayVisible ? 1 : 0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!kIsWeb) _MobileOverlay(tag: tag),
                if (kIsWeb) _WebOverlay(tag: tag),
              ],
            ),
          );
        },
      );
    }
  }
}
