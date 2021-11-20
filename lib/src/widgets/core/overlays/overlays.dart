part of 'package:fl_video_player/src/main.dart';

class _VideoOverlays extends StatelessWidget {
  final String tag;
  const _VideoOverlays({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
