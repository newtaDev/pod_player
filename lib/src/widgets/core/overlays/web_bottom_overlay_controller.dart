part of 'package:fl_video_player/src/fl_video_player.dart';

class _WebOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const _WebOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return MouseRegion(
      onHover: (event) => _flCtr.onOverlayHover(),
      onExit: (event) => _flCtr.onOverlayHoverExit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlVideoProgressBar(
              tag: tag,
              flProgressBarConfig: _flCtr.flProgressBarConfig,
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
                        _PlayPause(tag: tag),
                        GetBuilder<FlGetXVideoController>(
                          tag: tag,
                          id: 'volume',
                          builder: (_flCtr) => MaterialIconButton(
                            toolTipMesg: _flCtr.isMute
                                ? 'Unmute${kIsWeb ? ' (m)' : ''}'
                                : 'Mute${kIsWeb ? ' (m)' : ''}',
                            color: itemColor,
                            onPressed: _flCtr.toggleMute,
                            child: Icon(
                              _flCtr.isMute
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                            ),
                          ),
                        ),
                        GetBuilder<FlGetXVideoController>(
                          tag: tag,
                          id: 'video-progress',
                          builder: (_flCtr) {
                            return Text(
                              _flCtr.calculateVideoDuration(
                                _flCtr.videoPosition,
                              ),
                              style: durationTextStyle,
                            );
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
                          toolTipMesg: _flCtr.isFullScreen
                              ? 'Exit full screen${kIsWeb ? ' (f)' : ''}'
                              : 'Fullscreen${kIsWeb ? ' (f)' : ''}',
                          color: itemColor,
                          onPressed: () => _onFullScreenToggle(_flCtr, context),
                          child: Icon(
                            _flCtr.isFullScreen
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

  void _onFullScreenToggle(FlGetXVideoController _flCtr, BuildContext context) {
    if (_flCtr.isOverlayVisible) {
      if (_flCtr.isFullScreen) {
        if (kIsWeb) {
          _html.document.exitFullscreen();
          return;
        }
        _flCtr.exitFullScreenView(context, tag);
      } else {
        if (kIsWeb) {
          _html.document.documentElement?.requestFullscreen();
          return;
        }
        _flCtr.enableFullScreenView(context, tag);
      }
    } else {
      _flCtr.toggleVideoOverlay();
    }
  }
}
