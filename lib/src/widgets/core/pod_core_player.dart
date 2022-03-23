part of 'package:pod_player/src/pod_player.dart';

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
    final _podCtr = Get.find<FlGetXVideoController>(tag: tag);
    return Builder(
      builder: (_ctrx) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode:
              (_podCtr.isFullScreen ? FocusNode() : _podCtr.keyboardFocusWeb) ??
                  FocusNode(),
          onKey: (value) => _podCtr.onKeyBoardEvents(
            event: value,
            appContext: _ctrx,
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
                  id: 'podVideoState',
                  builder: (_podCtr) {
                    const loadingWidget = Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                    if (kIsWeb) {
                      switch (_podCtr.podVideoState) {
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
                      if (_podCtr.podVideoState == FlVideoState.loading) {
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
                  builder: (_podCtr) => _podCtr.isFullScreen
                      ? const SizedBox()
                      : GetBuilder<FlGetXVideoController>(
                          tag: tag,
                          id: 'overlay',
                          builder: (_podCtr) => _podCtr.isOverlayVisible ||
                                  !_podCtr.alwaysShowProgressBar
                              ? const SizedBox()
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FlVideoProgressBar(
                                    tag: tag,
                                    alignment: Alignment.bottomCenter,
                                    podProgressBarConfig:
                                        _podCtr.podProgressBarConfig,
                                  ),
                                ),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}
