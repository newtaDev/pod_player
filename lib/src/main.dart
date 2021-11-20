import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:video_player/video_player.dart';

import 'package:fl_video_player/fl_video_player.dart';

import 'controllers/fl_getx_video_controller.dart';
import 'utils/fl_enums.dart';
import 'utils/vimeo_models.dart';
import 'widgets/fl_video_progress_bar.dart';
import 'widgets/material_icon_button.dart';

class FlVideoPlayer extends StatefulWidget {
  final FlVideoController controller;
  final double frameAspectRatio;
  final double videoAspectRatio;

  FlVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
  }) : super(key: key) {
    _validate();
  }

  void _validate() {
    final flVideoController =
        Get.find<FlGetXVideoController>(tag: controller.getTag);

    switch (flVideoController.videoPlayerType) {
      case FlVideoPlayerType.network:
        assert(
          flVideoController.fromNetworkUrl != null,
          '''---------  FlVideoController( fromVideoUrl: )-------- parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.asset:
        assert(
          flVideoController.fromAssets != null,
          '''---------  FlVideoController( fromAssets: )-------- parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.vimeo:

        assert(
          flVideoController.fromVimeoVideoId != null ||
              flVideoController.fromVimeoUrls != null,
          '''---------  FlVideoController( fromVimeoVideoId: )-------- parameter is required  --------- OR  ---------  FlVideoController( fromVimeoUrls: )-------- parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.file:
        assert(
          flVideoController.fromFile != null,
          '''---------  FlVideoController( fromFile: )--------  parameter is required  ---------''',
        );
        break;
      case FlVideoPlayerType.auto:
        assert(
          flVideoController.fromNetworkUrl != null ||
              flVideoController.fromAssets != null ||
              flVideoController.fromVimeoVideoId != null ||
              flVideoController.fromVimeoUrls != null ||
              flVideoController.fromFile != null,
          '''--------- add required parameters to FlVideoController  ---------''',
        );
        break;
    }
  }

  @override
  _FlVideoPlayerState createState() => _FlVideoPlayerState();
}

class _FlVideoPlayerState extends State<FlVideoPlayer>
    with SingleTickerProviderStateMixin {
  late FlGetXVideoController _flCtr;
  // late String tag;
  @override
  void initState() {
    super.initState();
    // tag = widget.controller?.tag ?? UniqueKey().toString();
    _flCtr = Get.put(
      FlGetXVideoController(),
      permanent: true,
      tag: widget.controller.getTag,
    )
      ..playPauseCtr = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      )
      ..webFullScreenListner(context, widget.controller.getTag);

    if (kIsWeb) {
      //to disable mouse right click
      _html.document.onContextMenu.listen((event) => event.preventDefault());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _flCtr.flVideoStateChanger(FlVideoState.paused);
    _flCtr.hoverOverlayTimer?.cancel();
    _flCtr.leftDoubleTapTimer?.cancel();
    _flCtr.rightDoubleTapTimer?.cancel();
  }

  ///
  final circularProgressIndicator = const CircularProgressIndicator(
    backgroundColor: Colors.black87,
    color: Colors.white,
    strokeWidth: 2,
  );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: widget.controller.getTag,
      builder: (_) {
        return Center(
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: widget.frameAspectRatio,
              child: Center(
                child: _flCtr.videoCtr == null
                    ? circularProgressIndicator
                    : _flCtr.videoCtr!.value.isInitialized
                        ? _buildPlayer()
                        : circularProgressIndicator,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayer() {
    if (kIsWeb) {
      return GetBuilder<FlGetXVideoController>(
        tag: widget.controller.getTag,
        id: 'full-screen',
        builder: (_flCtr) {
          if (_flCtr.isFullScreen) return circularProgressIndicator;
          return FlPlayer(
            videoPlayerCtr: _flCtr.videoCtr!,
            videoAspectRatio: widget.videoAspectRatio,
            tag: widget.controller.getTag,
          );
        },
      );
    } else {
      return FlPlayer(
        videoPlayerCtr: _flCtr.videoCtr!,
        videoAspectRatio: widget.videoAspectRatio,
        tag: widget.controller.getTag,
      );
    }
  }
}

class FlPlayer extends StatelessWidget {
  final VideoPlayerController videoPlayerCtr;
  final double videoAspectRatio;
  final String tag;
  const FlPlayer({
    Key? key,
    required this.videoPlayerCtr,
    required this.videoAspectRatio,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (value) => flCtr.onKeyBoardEvents(
        event: value,
        appContext: context,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: videoAspectRatio,
              child: VideoPlayer(videoPlayerCtr),
            ),
          ),
          _VideoOverlays(tag: tag),
          GetBuilder<FlGetXVideoController>(
            tag: tag,
            id: 'flVideoState',
            builder: (_flCtr) => _flCtr.flVideoState == FlVideoState.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                //TODO: web play pause like youtube
                : const SizedBox(),
          ),
          if (!kIsWeb)
            GetBuilder<FlGetXVideoController>(
              tag: tag,
              id: 'full-screen',
              builder: (_flCtr) => _flCtr.isFullScreen
                  ? const SizedBox()
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: FlVideoProgressBar(
                        allowGestures: true,
                        tag: tag,
                        height: 5,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _VideoOverlays extends StatelessWidget {
  final String tag;
  const _VideoOverlays({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'overlay',
      builder: (_flCtr) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _flCtr.isOverlayVisible ? 1 : 0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!kIsWeb) MobileOverlay(tag: tag),
              if (kIsWeb) WebOverlay(tag: tag),
            ],
          ),
        );
      },
    );
  }
}

class WebOverlay extends StatelessWidget {
  final String tag;
  const WebOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.black38;
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return Stack(
      children: [
        Positioned.fill(
          child: VideoOverlayDetector(
            tag: tag,
            onTap: _flCtr.togglePlayPauseVideo,
            child: ColoredBox(
              color: overlayColor,
              child: const SizedBox.expand(),
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
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: true,
                  ),
                ),
              ),
              Expanded(
                child: IgnorePointer(
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // void _bottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => const _MobileBottomSheet(),
  //   );
  // }
}

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
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FlVideoProgressBar(
                tag: tag,
                allowGestures: true,
              ),
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
        } else {
          _flCtr.exitFullScreenView(context, tag);
        }
      } else {
        if (kIsWeb) {
          _html.document.documentElement?.requestFullscreen();
        } else {
          _flCtr.enableFullScreenView(context, tag);
        }
      }
    } else {
      _flCtr.toggleVideoOverlay();
    }
  }
}

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
            onPressed: () => _flCtr.isWebPopupOverlayOpen = true,
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
                    onTap: () {
                      _flCtr.changeVimeoVideoQuality(
                        e.quality,
                      );
                    },
                  ),
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

class MobileOverlay extends StatelessWidget {
  final String tag;

  const MobileOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: VideoOverlayDetector(
                tag: tag,
                onDoubleTap: _flCtr.onLeftDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: true,
                  ),
                ),
              ),
            ),
            VideoOverlayDetector(
              tag: tag,
              child: ColoredBox(
                color: overlayColor,
                child: SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: _PlayPause(tag: tag, size: 42),
                  ),
                ),
              ),
            ),
            Expanded(
              child: VideoOverlayDetector(
                tag: tag,
                onDoubleTap: _flCtr.onRightDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: _LeftRightDoubleTapBox(
                    tag: tag,
                    isLeft: false,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialIconButton(
                    toolTipMesg: 'More',
                    color: itemColor,
                    onPressed: () {
                      if (_flCtr.isOverlayVisible) {
                        _bottomSheet(context);
                      } else {
                        _flCtr.toggleVideoOverlay();
                      }
                    },
                    child: const Icon(
                      Icons.more_vert_rounded,
                    ),
                  ),
                ],
              ),
              _MobileOverlayBottomControlles(tag: tag)
            ],
          ),
        ),
      ],
    );
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MobileBottomSheet(tag: tag),
    );
  }
}

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
      builder: (_fl) => Padding(
        padding: _fl.isFullScreen ? const EdgeInsets.all(10) : EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_fl.isFullScreen)
              GetBuilder<FlGetXVideoController>(
                tag: tag,
                id: 'overlay',
                builder: (_flCtr) => Visibility(
                  visible: _flCtr.isOverlayVisible,
                  child: FlVideoProgressBar(allowGestures: true, tag: tag),
                ),
              ),
            Row(
              children: [
                GetBuilder<FlGetXVideoController>(
                    tag: tag,
                    id: 'video-progress',
                    builder: (_flCtr) {
                      return Text(
                          _flCtr.calculateVideoDuration(_flCtr.videoPosition),
                          style: const TextStyle(color: itemColor));
                    }),
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
          ],
        ),
      ),
    );
  }
}

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
                      builder: (context) => _VideoQualitySelectorMob(tag: tag));
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
                      builder: (context) => _VideoPlaybackSelector(tag: tag));
                });
              }),
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
                )),
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
                ?.map((e) => ListTile(
                      title: Text('${e.quality}p'),
                      onTap: () {
                        onTap != null ? onTap!() : Navigator.of(context).pop();

                        _flctr.changeVimeoVideoQuality(e.quality);
                      },
                    ))
                .toList() ??
            [],
      ),
    );
  }
}

class _VideoPlaybackSelector extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const _VideoPlaybackSelector({
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

class _LeftRightDoubleTapBox extends StatelessWidget {
  final String tag;
  final bool isLeft;
  const _LeftRightDoubleTapBox({
    Key? key,
    required this.tag,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'double-tap',
      builder: (_flctr) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _flctr.isLeftDbTapIconVisible && isLeft
                ? 1
                : _flctr.isRightDbTapIconVisible && !isLeft
                    ? 1
                    : 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    isLeft
                        ? 'packages/fl_video_player/assets/forward_left.json'
                        : 'packages/fl_video_player/assets/forward_right.json',
                  ),
                  if (isLeft
                      ? _flctr.isLeftDbTapIconVisible
                      : _flctr.isRightDbTapIconVisible)
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: Text(
                        '${_flctr.isLeftDbTapIconVisible ? _flctr.leftDoubleTapduration : _flctr.rightDubleTapduration} seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoOverlayDetector extends StatelessWidget {
  final Widget? child;
  final void Function()? onDoubleTap;
  final void Function()? onTap;
  final String tag;

  const VideoOverlayDetector({
    Key? key,
    this.child,
    this.onDoubleTap,
    this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return MouseRegion(
      onHover: (event) => _flCtr.onOverlayHover(),
      onExit: (event) => _flCtr.onOverlayHoverExit(),
      child: GestureDetector(
        onTap: onTap ?? _flCtr.toggleVideoOverlay,
        onDoubleTap: onDoubleTap,
        child: child,
      ),
    );
  }
}

class _PlayPause extends StatelessWidget {
  final double? size;
  final String tag;

  const _PlayPause({
    Key? key,
    this.size,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _flCtr = Get.find<FlGetXVideoController>(tag: tag);
    return GetBuilder<FlGetXVideoController>(
      tag: tag,
      id: 'overlay',
      builder: (_flctr) {
        return GetBuilder<FlGetXVideoController>(
          tag: tag,
          id: 'flVideoState',
          builder: (_f) => MaterialIconButton(
            toolTipMesg: _f.isvideoPlaying
                ? 'Pause${kIsWeb ? ' (space)' : ''}'
                : 'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                _flCtr.isOverlayVisible ? _flCtr.togglePlayPauseVideo : null,
            child: onStateChange(_flCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(FlGetXVideoController _flCtr) {
    if (kIsWeb) return _playPause(_flCtr);
    if (_flCtr.flVideoState == FlVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(_flCtr);
    }
  }

  Widget _playPause(FlGetXVideoController _flCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _flCtr.playPauseCtr,
      color: Colors.white,
      size: size,
    );
  }
}
