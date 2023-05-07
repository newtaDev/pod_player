part of 'package:pod_player/src/pod_player.dart';

class _WebOverlay extends StatelessWidget {
  final String tag;
  const _WebOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const overlayColor = Colors.black38;
    final _podCtr = Get.find<PodGetXVideoController>(tag: tag);
    return Stack(
      children: [
        Positioned.fill(
          child: _VideoGestureDetector(
            tag: tag,
            onTap: _podCtr.togglePlayPauseVideo,
            onDoubleTap: () => _podCtr.toggleFullScreenOnWeb(context, tag),
            child: const ColoredBox(
              color: overlayColor,
              child: SizedBox.expand(),
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
          child: GetBuilder<PodGetXVideoController>(
            tag: tag,
            id: 'double-tap',
            builder: (_podCtr) {
              return Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      child: DoubleTapIcon(
                        onDoubleTap: () {},
                        tag: tag,
                        isForward: false,
                        iconOnly: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      child: DoubleTapIcon(
                        onDoubleTap: () {},
                        tag: tag,
                        isForward: true,
                        iconOnly: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        IgnorePointer(child: _podCtr.videoTitle ?? const SizedBox()),
      ],
    );
  }
}

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
                                ? _podCtr.podPlayerLabels.unmute ??
                                    'Unmute${kIsWeb ? ' (m)' : ''}'
                                : _podCtr.podPlayerLabels.mute ??
                                    'Mute${kIsWeb ? ' (m)' : ''}',
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
                              ? _podCtr.podPlayerLabels.exitFullScreen ??
                                  'Exit full screen${kIsWeb ? ' (f)' : ''}'
                              : _podCtr.podPlayerLabels.fullscreen ??
                                  'Fullscreen${kIsWeb ? ' (f)' : ''}',
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
