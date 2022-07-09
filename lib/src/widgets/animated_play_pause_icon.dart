part of 'package:pod_player/src/pod_player.dart';

class _AnimatedPlayPauseIcon extends StatefulWidget {
  final double? size;
  final String tag;

  const _AnimatedPlayPauseIcon({
    Key? key,
    this.size,
    required this.tag,
  }) : super(key: key);

  @override
  State<_AnimatedPlayPauseIcon> createState() => _AnimatedPlayPauseIconState();
}

class _AnimatedPlayPauseIconState extends State<_AnimatedPlayPauseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _payCtr;
  late PodGetXVideoController _podCtr;
  @override
  void initState() {
    _podCtr = Get.find<PodGetXVideoController>(tag: widget.tag);
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _podCtr.addListenerId('podVideoState', playPauseListner);
    if (_podCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_podCtr.podVideoState == PodVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (_podCtr.podVideoState == PodVideoState.paused) {
        if (mounted) _payCtr.reverse();
      }
    });
  }

  @override
  void dispose() {
    // podLog('Play-pause-controller-disposed');
    _payCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PodGetXVideoController>(
      tag: widget.tag,
      id: 'overlay',
      builder: (_podCtr) {
        return GetBuilder<PodGetXVideoController>(
          tag: widget.tag,
          id: 'podVideoState',
          builder: (_f) => MaterialIconButton(
            toolTipMesg: _f.isvideoPlaying
                ? _podCtr.podPlayerLabels.pause ??
                    'Pause${kIsWeb ? ' (space)' : ''}'
                : _podCtr.podPlayerLabels.play ??
                    'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                _podCtr.isOverlayVisible ? _podCtr.togglePlayPauseVideo : null,
            child: onStateChange(_podCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(PodGetXVideoController _podCtr) {
    if (kIsWeb) return _playPause(_podCtr);
    if (_podCtr.podVideoState == PodVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(_podCtr);
    }
  }

  Widget _playPause(PodGetXVideoController _podCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
