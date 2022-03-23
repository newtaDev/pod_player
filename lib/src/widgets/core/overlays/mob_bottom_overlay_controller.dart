part of 'package:pod_player/src/pod_player.dart';

class _MobileOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const _MobileOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'full-screen',
      builder: (_podCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              GetBuilder<FlGetXVideoController>(
                tag: tag,
                id: 'video-progress',
                builder: (_podCtr) {
                  return Text(
                    _podCtr.calculateVideoDuration(_podCtr.videoPosition),
                    style: const TextStyle(color: itemColor),
                  );
                },
              ),
              const Text(
                ' / ',
                style: durationTextStyle,
              ),
              Text(
                _podCtr.calculateVideoDuration(_podCtr.videoDuration),
                style: durationTextStyle,
              ),
              const Spacer(),
              MaterialIconButton(
                toolTipMesg: _podCtr.isFullScreen
                    ? 'Exit full screen${kIsWeb ? ' (f)' : ''}'
                    : 'Fullscreen${kIsWeb ? ' (f)' : ''}',
                color: itemColor,
                onPressed: () {
                  if (_podCtr.isOverlayVisible) {
                    if (_podCtr.isFullScreen) {
                      _podCtr.disableFullScreen(context, tag);
                    } else {
                      _podCtr.enableFullScreen(tag);
                    }
                  } else {
                    _podCtr.toggleVideoOverlay();
                  }
                },
                child: Icon(
                  _podCtr.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            ],
          ),
          GetBuilder<FlGetXVideoController>(
            tag: tag,
            id: 'overlay',
            builder: (_podCtr) {
              if (_podCtr.isFullScreen) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: Visibility(
                    visible: _podCtr.isOverlayVisible,
                    child: FlVideoProgressBar(
                      tag: tag,
                      alignment: Alignment.topCenter,
                      podProgressBarConfig: _podCtr.podProgressBarConfig,
                    ),
                  ),
                );
              }
              return FlVideoProgressBar(
                tag: tag,
                alignment: Alignment.bottomCenter,
                podProgressBarConfig: _podCtr.podProgressBarConfig,
              );
            },
          ),
        ],
      ),
    );
  }
}
