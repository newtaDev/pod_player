part of 'package:fl_video_player/src/main.dart';

class _MobileOverlay extends StatelessWidget {
  final String tag;

  const _MobileOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: _VideoGestureDetector(
                tag: tag,
                onDoubleTap: _flCtr.onLeftDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: true,
                  ),
                ),
              ),
            ),
            _VideoGestureDetector(
              tag: tag,
              child: ColoredBox(
                color: overlayColor,
                child: SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: _PlayPause(tag: tag, size: 42),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _VideoGestureDetector(
                tag: tag,
                onDoubleTap: _flCtr.onRightDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: false,
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialIconButton(
                  toolTipMesg: 'More',
                  color: itemColor,
                  onPressed: () {
                    if (_flCtr.isOverlayVisible) {
                      _bottomSheet(context);
                    } else {
                      _flCtr.toggleVideoOverlay();
                    }
                  },
                  child: const Icon(
                    Icons.more_vert_rounded,
                  ),
                ),
              ],
            ),
            _MobileOverlayBottomControlles(tag: tag)
          ],
        ),
      ],
    );
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MobileBottomSheet(tag: tag),
    );
  }
}




class _LeftRightDoubleTapBox extends StatelessWidget {
  final String tag;
  final bool isLeft;
  const _LeftRightDoubleTapBox({
    Key? key,
    required this.tag,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'double-tap',
      builder: (_flctr) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _flctr.isLeftDbTapIconVisible && isLeft
                ? 1
                : _flctr.isRightDbTapIconVisible && !isLeft
                    ? 1
                    : 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    isLeft
                        ? 'packages/fl_video_player/assets/forward_left.json'
                        : 'packages/fl_video_player/assets/forward_right.json',
                  ),
                  if (isLeft
                      ? _flctr.isLeftDbTapIconVisible
                      : _flctr.isRightDbTapIconVisible)
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: Text(
                        '${_flctr.isLeftDbTapIconVisible ? _flctr.leftDoubleTapduration : _flctr.rightDubleTapduration} Sec',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
