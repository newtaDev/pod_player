part of 'package:pod_player/src/pod_player.dart';

class _VideoOverlays extends StatelessWidget {
  final String tag;
  const _VideoOverlays({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _podCtr = Get.find<FlGetXVideoController>(tag: tag);
    if (_podCtr.overlayBuilder != null) {
      return GetBuilder<FlGetXVideoController>(
        id: 'update-all',
        tag: tag,
        builder: (_podCtr) {
          ///Custom overlay
          final _progressBar = FlVideoProgressBar(
            tag: tag,
            podProgressBarConfig: _podCtr.podProgressBarConfig,
          );
          final overlayOptions = OverLayOptions(
            podVideoState: _podCtr.podVideoState,
            videoDuration: _podCtr.videoDuration,
            videoPosition: _podCtr.videoPosition,
            isFullScreen: _podCtr.isFullScreen,
            isLooping: _podCtr.isLooping,
            isOverlayVisible: _podCtr.isOverlayVisible,
            isMute: _podCtr.isMute,
            autoPlay: _podCtr.autoPlay,
            currentVideoPlaybackSpeed: _podCtr.currentPaybackSpeed,
            videoPlayBackSpeeds: _podCtr.videoPlaybackSpeeds,
            videoPlayerType: _podCtr.videoPlayerType,
            podProgresssBar: _progressBar,
          );
          return Stack(
            children: [
              Positioned.fill(
                child: _VideoGestureDetector(
                  tag: tag,
                  onTap: _podCtr.togglePlayPauseVideo,
                  onDoubleTap: () => _podCtr.toggleFullScreenOnWeb(context, tag),
                  child: const ColoredBox(
                    color: Colors.black38,
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              _podCtr.overlayBuilder?.call(overlayOptions) ?? const SizedBox(),
            ],
          );
        },
      );
    } else {
      ///Built in overlay
      return GetBuilder<FlGetXVideoController>(
        tag: tag,
        id: 'overlay',
        builder: (_podCtr) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _podCtr.isOverlayVisible ? 1 : 0,
            child: Stack(
              fit: StackFit.passthrough,
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
