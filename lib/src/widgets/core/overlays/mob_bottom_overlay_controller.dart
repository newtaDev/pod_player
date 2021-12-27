part of 'package:fl_video_player/src/main.dart';

class _MobileOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const _MobileOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'full-screen',
      builder: (_fl) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              GetBuilder<FlGetXVideoController>(
                tag: tag,
                id: 'video-progress',
                builder: (_flCtr) {
                  return Text(
                      _flCtr.calculateVideoDuration(_flCtr.videoPosition),
                      style: const TextStyle(color: itemColor));
                },
              ),
              const Text(
                ' / ',
                style: durationTextStyle,
              ),
              Text(
                _flCtr.calculateVideoDuration(_flCtr.videoDuration),
                style: durationTextStyle,
              ),
              const Spacer(),
              MaterialIconButton(
                toolTipMesg: _flCtr.isFullScreen
                    ? 'Exit full screen${kIsWeb ? ' (f)' : ''}'
                    : 'Fullscreen${kIsWeb ? ' (f)' : ''}',
                color: itemColor,
                onPressed: () {
                  if (_flCtr.isOverlayVisible) {
                    if (_fl.isFullScreen) {
                      _flCtr.exitFullScreenView(context, tag);
                    } else {
                      _flCtr.enableFullScreenView(context, tag);
                    }
                  } else {
                    _flCtr.toggleVideoOverlay();
                  }
                },
                child: Icon(
                  _fl.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            ],
          ),
          GetBuilder<FlGetXVideoController>(
            tag: tag,
            id: 'overlay',
            builder: (_flCtr) {
              if (_fl.isFullScreen) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: Visibility(
                    visible: _flCtr.isOverlayVisible,
                    child: FlVideoProgressBar(
                      tag: tag,
                      alignment: Alignment.topCenter,
                      flProgressBarConfig: _flCtr.flProgressBarConfig,
                    ),
                  ),
                );
              }
              return FlVideoProgressBar(
                tag: tag,
                alignment: Alignment.bottomCenter,
                      flProgressBarConfig: _flCtr.flProgressBarConfig,
              );
            },
          ),
        ],
      ),
    );
  }
}
