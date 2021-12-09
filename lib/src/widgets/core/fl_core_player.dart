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
      focusNode: flCtr.isFullScreen
          ? flCtr.keyboardFocusOnFullScreen!
          : flCtr.keyboardFocus!,
      onKey: (value) => flCtr.onKeyBoardEvents(
        event: value,
        appContext: context,
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
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: FlVideoProgressBar(
                        allowGestures: true,
                        tag: tag,
                        height: 5,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
