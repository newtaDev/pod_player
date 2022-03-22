part of 'package:pod_player/src/fl_video_player.dart';

class _MobileBottomSheet extends StatelessWidget {
  final String tag;

  const _MobileBottomSheet({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      builder: (_flCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_flCtr.videoPlayerType == FlVideoPlayerType.vimeo)
            _bottomSheetTiles(
              title: 'Quality',
              icon: Icons.video_settings_rounded,
              subText: '${_flCtr.vimeoPlayingVideoQuality}p',
              onTap: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _VideoQualitySelectorMob(tag: tag),
                  );
                });
                // await Future.delayed(
                //   const Duration(milliseconds: 100),
                // );
              },
            ),
          _bottomSheetTiles(
            title: 'Loop video',
            icon: Icons.loop_rounded,
            subText: _flCtr.isLooping ? 'On' : 'Off',
            onTap: () {
              Navigator.of(context).pop();
              _flCtr.toggleLooping();
            },
          ),
          _bottomSheetTiles(
            title: 'Playback speed',
            icon: Icons.slow_motion_video_rounded,
            subText: _flCtr.currentPaybackSpeed,
            onTap: () {
              Navigator.of(context).pop();
              Timer(const Duration(milliseconds: 100), () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => _VideoPlaybackSelectorMob(tag: tag),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  ListTile _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              title,
            ),
            if (subText != null) const SizedBox(width: 6),
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

class _VideoQualitySelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const _VideoQualitySelectorMob({
    Key? key,
    this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flctr = Get.find<FlGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _flctr.vimeoVideoUrls
                ?.map(
                  (e) => ListTile(
                    title: Text('${e.quality}p'),
                    onTap: () {
                      onTap != null ? onTap!() : Navigator.of(context).pop();

                      _flctr.changeVimeoVideoQuality(e.quality);
                    },
                  ),
                )
                .toList() ??
            [],
      ),
    );
  }
}

class _VideoPlaybackSelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const _VideoPlaybackSelectorMob({
    Key? key,
    this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flctr = Get.find<FlGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _flctr.videoPlaybackSpeeds
            .map(
              (e) => ListTile(
                title: Text(e),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();
                  _flctr.setVideoPlayBack(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
