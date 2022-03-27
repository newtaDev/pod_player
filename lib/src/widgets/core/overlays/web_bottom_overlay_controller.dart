part of 'package:pod_player/src/pod_player.dart';

class _WebOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const _WebOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _podCtr = Get.find<PodGetXVideoController>(tag: tag);
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return MouseRegion(
      onHover: (event) => _podCtr.onOverlayHover(),
      onExit: (event) => _podCtr.onOverlayHoverExit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PodProgressBar(
              tag: tag,
              podProgressBarConfig: _podCtr.podProgressBarConfig,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        _AnimatedPlayPauseIcon(tag: tag),
                        GetBuilder<PodGetXVideoController>(
                          tag: tag,
                          id: 'volume',
                          builder: (_podCtr) => MaterialIconButton(
                            toolTipMesg: _podCtr.isMute
                                ? 'Unmute${kIsWeb ? ' (m)' : ''}'
                                : 'Mute${kIsWeb ? ' (m)' : ''}',
                            color: itemColor,
                            onPressed: _podCtr.toggleMute,
                            child: Icon(
                              _podCtr.isMute
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                            ),
                          ),
                        ),
                        GetBuilder<PodGetXVideoController>(
                          tag: tag,
                          id: 'video-progress',
                          builder: (_podCtr) {
                            return Row(
                              children: [
                                Text(
                                  _podCtr.calculateVideoDuration(
                                    _podCtr.videoPosition,
                                  ),
                                  style: durationTextStyle,
                                ),
                                const Text(
                                  ' / ',
                                  style: durationTextStyle,
                                ),
                                Text(
                                  _podCtr.calculateVideoDuration(
                                    _podCtr.videoDuration,
                                  ),
                                  style: durationTextStyle,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        _WebSettingsDropdown(tag: tag),
                        MaterialIconButton(
                          toolTipMesg: _podCtr.isFullScreen
                              ? 'Exit full screen${kIsWeb ? ' (f)' : ''}'
                              : 'Fullscreen${kIsWeb ? ' (f)' : ''}',
                          color: itemColor,
                          onPressed: () =>
                              _onFullScreenToggle(_podCtr, context),
                          child: Icon(
                            _podCtr.isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onFullScreenToggle(
    PodGetXVideoController _podCtr,
    BuildContext context,
  ) {
    if (_podCtr.isOverlayVisible) {
      if (_podCtr.isFullScreen) {
        if (kIsWeb) {
          _html.document.exitFullscreen();
          _podCtr.disableFullScreen(context, tag);
          return;
        } else {
          _podCtr.disableFullScreen(context, tag);
        }
      } else {
        if (kIsWeb) {
          _html.document.documentElement?.requestFullscreen();
          _podCtr.enableFullScreen(tag);
          return;
        } else {
          _podCtr.enableFullScreen(tag);
        }
      }
    } else {
      _podCtr.toggleVideoOverlay();
    }
  }
}
