part of 'package:pod_player/src/fl_video_player.dart';

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
        selectedRowColor: Colors.white,
      ),
      child: GetBuilder<FlGetXVideoController>(
        tag: widget.tag,
        builder: (_flCtr) {
          return MaterialIconButton(
            toolTipMesg: 'Settings',
            color: Colors.white,
            child: const Icon(Icons.settings),
            onPressed: () =>_flCtr.isFullScreen? _flCtr.isWebPopupOverlayOpen = true: _flCtr.isWebPopupOverlayOpen = false,
            onTapDown: (details) async {
              final _settingsMenu = await showMenu<String>(
                context: context,
                items: [
                  if (_flCtr.vimeoVideoUrls != null ||
                      (_flCtr.vimeoVideoUrls?.isNotEmpty ?? false))
                    PopupMenuItem(
                      value: 'OUALITY',
                      child: _bottomSheetTiles(
                        title: 'Quality',
                        icon: Icons.video_settings_rounded,
                        subText: '${_flCtr.vimeoPlayingVideoQuality}p',
                      ),
                    ),
                  PopupMenuItem(
                    value: 'LOOP',
                    child: _bottomSheetTiles(
                      title: 'Loop video',
                      icon: Icons.loop_rounded,
                      subText: _flCtr.isLooping ? 'On' : 'Off',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'SPEED',
                    child: _bottomSheetTiles(
                      title: 'Playback speed',
                      icon: Icons.slow_motion_video_rounded,
                      subText: _flCtr.currentPaybackSpeed,
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
                  await _onVimeoQualitySelect(details, _flCtr);
                  break;
                case 'SPEED':
                  await _onPlaybackSpeedSelect(details, _flCtr);
                  break;
                case 'LOOP':
                  _flCtr.isWebPopupOverlayOpen = false;
                  await _flCtr.toggleLooping();
                  break;
                default:
                  _flCtr.isWebPopupOverlayOpen = false;
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _onPlaybackSpeedSelect(
    TapDownDetails details,
    FlGetXVideoController _flCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: _flCtr.videoPlaybackSpeeds
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text(e),
              ),
              onTap: () {
                _flCtr.setVideoPlayBack(e);
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
    _flCtr.isWebPopupOverlayOpen = false;
  }

  Future<void> _onVimeoQualitySelect(
    TapDownDetails details,
    FlGetXVideoController _flCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: _flCtr.vimeoVideoUrls
              ?.map(
                (e) => PopupMenuItem(
                  child: ListTile(
                    title: Text('${e.quality}p'),
                  ),
                  onTap: () {
                    _flCtr.changeVimeoVideoQuality(
                      e.quality,
                    );
                  },
                ),
              )
              .toList() ??
          [],
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        // ignore: use_build_context_synchronously
        MediaQuery.of(context).size,
      ),
    );
    _flCtr.isWebPopupOverlayOpen = false;
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
