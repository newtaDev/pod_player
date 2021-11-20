part of 'package:fl_video_player/src/main.dart';

class _WebOverlay extends StatelessWidget {
  final String tag;
  const _WebOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.black38;
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return Stack(
      children: [
        Positioned.fill(
          child: _VideoGestureDetector(
            tag: tag,
            onTap: _flCtr.togglePlayPauseVideo,
            child: ColoredBox(
              color: overlayColor,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _WebOverlayBottomControlles(
            tag: tag,
          ),
        ),
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: true,
                  ),
                ),
              ),
              Expanded(
                child: IgnorePointer(
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // void _bottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => const _MobileBottomSheet(),
  //   );
  // }
}
