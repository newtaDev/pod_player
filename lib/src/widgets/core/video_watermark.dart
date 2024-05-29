part of 'package:pod_player/src/pod_player.dart';

class _VideoWatermark extends StatelessWidget {
  final String tag;

  const _VideoWatermark({
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GetBuilder<PodGetXVideoController>(
        tag: tag,
        id: 'watermark',
        builder: (podCtr) {
          if (podCtr.videoWatermark == null || !podCtr.isWatermarkVisible) {
            return const SizedBox.shrink();
          }

          return podCtr.videoWatermark!;
        },
      ),
    );
  }
}
