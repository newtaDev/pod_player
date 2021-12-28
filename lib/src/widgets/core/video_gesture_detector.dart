part of 'package:fl_video_player/src/fl_video_player.dart';

class _VideoGestureDetector extends StatelessWidget {
  final Widget? child;
  final void Function()? onDoubleTap;
  final void Function()? onTap;
  final String tag;

  const _VideoGestureDetector({
    Key? key,
    this.child,
    this.onDoubleTap,
    this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return MouseRegion(
      onHover: (event) => _flCtr.onOverlayHover(),
      onExit: (event) => _flCtr.onOverlayHoverExit(),
      child: GestureDetector(
        onTap: onTap ?? _flCtr.toggleVideoOverlay,
        onDoubleTap: onDoubleTap,
        child: child,
      ),
    );
  }
}