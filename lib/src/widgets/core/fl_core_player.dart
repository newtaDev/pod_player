part of 'package:fl_video_player/src/main.dart';

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
          GetBuilder<FlGetXVideoController>(
            tag: tag,
            id: 'flVideoState',
            builder: (_flCtr) => _flCtr.flVideoState == FlVideoState.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                //TODO: web play pause like youtube
                : const SizedBox(),
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
