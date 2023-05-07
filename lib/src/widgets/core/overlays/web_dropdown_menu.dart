part of 'package:pod_player/src/pod_player.dart';

class _WebSettingsDropdown extends StatefulWidget {
  final String tag;

  const _WebSettingsDropdown({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<_WebSettingsDropdown> createState() => _WebSettingsDropdownState();
}

class _WebSettingsDropdownState extends State<_WebSettingsDropdown> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.white,
      ),
      child: GetBuilder<PodGetXVideoController>(
        tag: widget.tag,
        builder: (_podCtr) {
          return MaterialIconButton(
            toolTipMesg: _podCtr.podPlayerLabels.settings,
            color: Colors.white,
            child: const Icon(Icons.settings),
            onPressed: () => _podCtr.isFullScreen
                ? _podCtr.isWebPopupOverlayOpen = true
                : _podCtr.isWebPopupOverlayOpen = false,
            onTapDown: (details) async {
              final _settingsMenu = await showMenu<String>(
                context: context,
                items: [
                  if (_podCtr.vimeoOrVideoUrls.isNotEmpty)
                    PopupMenuItem(
                      value: 'OUALITY',
                      child: _bottomSheetTiles(
                        title: _podCtr.podPlayerLabels.quality,
                        icon: Icons.video_settings_rounded,
                        subText: '${_podCtr.vimeoPlayingVideoQuality}p',
                      ),
                    ),
                  PopupMenuItem(
                    value: 'LOOP',
                    child: _bottomSheetTiles(
                      title: _podCtr.podPlayerLabels.loopVideo,
                      icon: Icons.loop_rounded,
                      subText: _podCtr.isLooping
                          ? _podCtr.podPlayerLabels.optionEnabled
                          : _podCtr.podPlayerLabels.optionDisabled,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'SPEED',
                    child: _bottomSheetTiles(
                      title: _podCtr.podPlayerLabels.playbackSpeed,
                      icon: Icons.slow_motion_video_rounded,
                      subText: _podCtr.currentPaybackSpeed,
                    ),
                  ),
                ],
                position: RelativeRect.fromSize(
                  details.globalPosition & Size.zero,
                  MediaQuery.of(context).size,
                ),
              );
              switch (_settingsMenu) {
                case 'OUALITY':
                  await _onVimeoQualitySelect(details, _podCtr);
                  break;
                case 'SPEED':
                  await _onPlaybackSpeedSelect(details, _podCtr);
                  break;
                case 'LOOP':
                  _podCtr.isWebPopupOverlayOpen = false;
                  await _podCtr.toggleLooping();
                  break;
                default:
                  _podCtr.isWebPopupOverlayOpen = false;
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _onPlaybackSpeedSelect(
    TapDownDetails details,
    PodGetXVideoController _podCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: _podCtr.videoPlaybackSpeeds
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text(e),
              ),
              onTap: () {
                _podCtr.setVideoPlayBack(e);
              },
            ),
          )
          .toList(),
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        // ignore: use_build_context_synchronously
        MediaQuery.of(context).size,
      ),
    );
    _podCtr.isWebPopupOverlayOpen = false;
  }

  Future<void> _onVimeoQualitySelect(
    TapDownDetails details,
    PodGetXVideoController _podCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: _podCtr.vimeoOrVideoUrls
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text('${e.quality}p'),
              ),
              onTap: () {
                _podCtr.changeVideoQuality(
                  e.quality,
                );
              },
            ),
          )
          .toList(),
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        // ignore: use_build_context_synchronously
        MediaQuery.of(context).size,
      ),
    );
    _podCtr.isWebPopupOverlayOpen = false;
  }

  Widget _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Text(
              title,
            ),
            if (subText != null) const SizedBox(width: 10),
            if (subText != null)
              const SizedBox(
                height: 4,
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
