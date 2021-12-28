part of 'package:fl_video_player/src/fl_video_player.dart';

class FlCorePlayer extends StatelessWidget {
  final VideoPlayerController videoPlayerCtr;
  final double videoAspectRatio;
  final String tag;
  const FlCorePlayer({
    Key? key,
    required this.videoPlayerCtr,
    required this.videoAspectRatio,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return RawKeyboardListener(
      autofocus: true,
      focusNode: (flCtr.isFullScreen ? FocusNode() : flCtr.keyboardFocusWeb) ??
          FocusNode(),
      onKey: (value) => flCtr.onKeyBoardEvents(
        event: value,
        appContext: context,
        tag: tag,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: videoAspectRatio,
              child: VideoPlayer(videoPlayerCtr),
            ),
          ),
          _VideoOverlays(tag: tag),
          IgnorePointer(
            child: GetBuilder<FlGetXVideoController>(
              tag: tag,
              id: 'flVideoState',
              builder: (_flCtr) {
                const loadingWidget = Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                );
                if (kIsWeb) {
                  switch (_flCtr.flVideoState) {
                    case FlVideoState.loading:
                      return loadingWidget;
                    case FlVideoState.paused:
                      return const Center(
                        child: Icon(
                          Icons.play_arrow,
                          size: 45,
                          color: Colors.white,
                        ),
                      );
                    case FlVideoState.playing:
                      return Center(
                        child: TweenAnimationBuilder<double>(
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: child,
                          ),
                          tween: Tween<double>(begin: 1, end: 0),
                          duration: const Duration(seconds: 1),
                          child: const Icon(
                            Icons.pause,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      );
                    case FlVideoState.error:
                      return const SizedBox();
                  }
                } else {
                  if (flCtr.flVideoState == FlVideoState.loading) {
                    return loadingWidget;
                  }
                  return const SizedBox();
                }
              },
            ),
          ),
          if (!kIsWeb)
            GetBuilder<FlGetXVideoController>(
              tag: tag,
              id: 'full-screen',
              builder: (_flCtr) => _flCtr.isFullScreen
                  ? const SizedBox()
                  : GetBuilder<FlGetXVideoController>(
                      tag: tag,
                      id: 'overlay',
                      builder: (_flCtr) => _flCtr.isOverlayVisible ||
                              !_flCtr.alwaysShowProgressBar
                          ? const SizedBox()
                          : Align(
                              alignment: Alignment.bottomCenter,
                              child: FlVideoProgressBar(
                                tag: tag,
                                alignment: Alignment.bottomCenter,
                                flProgressBarConfig: _flCtr.flProgressBarConfig,
                              ),
                            ),
                    ),
            ),
        ],
      ),
    );
  }
}
