import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../fl_enums.dart';
import '../fl_video_controller.dart';

class FlVideoProgressBar extends StatefulWidget {
  const FlVideoProgressBar({
    Key? key,
    this.colors,
    required this.allowGestures,
    this.padding = EdgeInsets.zero,
    this.height = 20,
  }) : super(key: key);

  final VideoProgressColors? colors;

  final bool allowGestures;

  final double height;

  final EdgeInsets padding;

  @override
  _FlVideoProgressBarState createState() => _FlVideoProgressBarState();
}

class _FlVideoProgressBarState extends State<FlVideoProgressBar> {
  VideoProgressColors get colors =>
      widget.colors ??
      VideoProgressColors(
        backgroundColor: Colors.grey.withOpacity(0.5),
        bufferedColor: Colors.grey[500]!,
      );

  double? relativeVal;
  late double relativeWidth;
  bool isHovered = false;
  final _flCtr = Get.find<FlVideoController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlVideoController>(
      id: 'video-progress',
      builder: (controller) {
        Widget progressIndicator;
        if (_flCtr.videoCtr!.value.isInitialized) {
          final int duration = _flCtr.videoCtr!.value.duration.inMilliseconds;
          final int position = _flCtr.videoCtr!.value.position.inMilliseconds;

          int maxBuffering = 0;
          for (final DurationRange range in _flCtr.videoCtr!.value.buffered) {
            final int end = range.end.inMilliseconds;
            if (end > maxBuffering) {
              maxBuffering = end;
            }
          }
          relativeVal = position / duration;
          final double barHeight = _flCtr.overlayVisible
              ? 20
              : isHovered
                  ? 20
                  : widget.height;
          const alignmentLoc = Alignment.bottomLeft;
          progressIndicator = _progressWidget(
            alignmentLoc,
            barHeight,
            maxBuffering,
            duration,
            position,
          );
        } else {
          progressIndicator = LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: colors.backgroundColor,
          );
        }
        if (widget.allowGestures) {
          return Padding(
            padding: widget.padding,
            child: _VideoGestureDetector(
              controller: _flCtr.videoCtr!,
              onHoverStart: _onHoverStart,
              onExit: _onExit,
              onHorizontalDrag: onHrDrag,
              onDragStart: () => isHovered = true,
              onDragEnd: () => isHovered = false,
              child: progressIndicator,
            ),
          );
        } else {
          return progressIndicator;
        }
      },
    );
  }

  void onHrDrag(double val) {
    relativeVal = val;
    if (kIsWeb) _flCtr.isShowOverlay(true);
  }

  Stack _progressWidget(
    Alignment alignmentLoc,
    double barHeight,
    int maxBuffering,
    int duration,
    int position,
  ) {
    return Stack(
      alignment: alignmentLoc,
      fit: StackFit.passthrough,
      children: <Widget>[
        SizedBox(
          height: barHeight,
          child: Align(
            alignment: alignmentLoc,
            child: LinearProgressIndicator(
              value: maxBuffering / duration,
              valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
              backgroundColor: colors.backgroundColor,
            ),
          ),
        ),
        _VideoProgressBar(
            position: position,
            duration: duration,
            relativeVal: relativeVal,
            height: widget.height,
            isHovered: isHovered,
            showThumbHandler: isHovered ||
                _flCtr.overlayVisible ||
                _flCtr.flVideoState == FlVideoState.paused,
            colors: colors,
            alignmentLoc: alignmentLoc),

        //*old
        //  LayoutBuilder(
        //   builder: (context, constraints) {
        //     relativeWidth =
        //         constraints.maxWidth * (relativeVal ?? (position / duration));
        //     return SizedBox(
        //       height: barHeight,
        //       width: relativeWidth,
        //       child: Center(
        //         child: Stack(
        //           children: [
        //             Align(
        //               alignment: alignmentLoc,
        //               child: ColoredBox(
        //                 color: colors.playedColor,
        //                 child: SizedBox(
        //                   // duration: const Duration(milliseconds: 50),
        //                   height: isHovered ? 6 : 5,
        //                   width: relativeWidth,
        //                 ),
        //               ),
        //             ),
        //             Align(
        //               alignment: Alignment.bottomRight,
        //               child: AnimatedContainer(
        //                 duration: const Duration(milliseconds: 200),
        //                 transform: Matrix4.identity()
        //                   ..translate(
        //                       0, _flCtr.overlayVisible || isHovered ? 7 : 0),
        //                 height: _flCtr.overlayVisible
        //                     ? 20
        //                     : isHovered
        //                         ? 20
        //                         : 0,
        //                 width: _flCtr.overlayVisible
        //                     ? 15
        //                     : isHovered
        //                         ? 15
        //                         : 0,
        //                 decoration: BoxDecoration(
        //                   shape: BoxShape.circle,
        //                   color: colors.playedColor,
        //                   boxShadow: _flCtr.overlayVisible && isHovered
        //                       ? [
        //                           BoxShadow(
        //                             spreadRadius: 4,
        //                             color:
        //                                 colors.playedColor.withOpacity(0.3),
        //                           )
        //                         ]
        //                       : [],
        //                 ),
        //               ),
        //             )
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  void _onHoverStart(event) {
    if (kIsWeb) isHovered = true;
  }

  void _onExit(event) {
    if (kIsWeb) {
      if (isHovered == true) {
        if (mounted) setState(() => isHovered = false);
      }
    }
  }
}

class _VideoProgressBar extends StatelessWidget {
  final double? relativeVal;
  final int position;
  final int duration;
  final double height;
  final bool isHovered;
  final VideoProgressColors colors;
  final Alignment alignmentLoc;
  final bool showThumbHandler;
  const _VideoProgressBar({
    Key? key,
    this.relativeVal,
    required this.position,
    required this.duration,
    required this.height,
    required this.isHovered,
    required this.colors,
    required this.alignmentLoc,
    required this.showThumbHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///Progress bar height
    final double barHeight = showThumbHandler ? 20 : height;

    ///Progress bar width
    double relativeWidth;

    ///Progress circle config
    final double _progresscircleHeight = showThumbHandler ? 20 : 0;
    final double _progresscircleWidth = showThumbHandler ? 15 : 0;
    final List<BoxShadow> _progressCircleShadow = showThumbHandler && isHovered
        ? [
            BoxShadow(
              spreadRadius: 4,
              color: colors.playedColor.withOpacity(0.3),
            )
          ]
        : [];
    return LayoutBuilder(
      builder: (context, constraints) {
        relativeWidth =
            constraints.maxWidth * (relativeVal ?? (position / duration));
        return SizedBox(
          height: barHeight,
          width: relativeWidth,
          child: Center(
            child: Stack(
              children: [
                Align(
                  alignment: alignmentLoc,
                  child: ColoredBox(
                    color: colors.playedColor,
                    child: SizedBox(
                      height: isHovered ? 6 : 5,
                      width: relativeWidth,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: showThumbHandler ? 1 : 0,
                    child: SizedBox(
                      height: _progresscircleHeight,
                      width: _progresscircleWidth,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        alignment: Alignment.center,
                        transform: Matrix4.translationValues(
                            0, _progresscircleHeight != 0 ? 7 : 0, 0),
                        // ..translate(
                        // 0,
                        // _progresscircleHeight != 0 ? 7 : 0,
                        // ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.playedColor,
                          boxShadow: _progressCircleShadow,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoGestureDetector extends StatefulWidget {
  const _VideoGestureDetector({
    Key? key,
    required this.child,
    required this.controller,
    this.onHoverStart,
    this.onExit,
    this.onHorizontalDrag,
    this.onDragStart,
    this.onDragEnd,
  }) : super(key: key);

  final Widget child;
  final VideoPlayerController controller;
  final void Function(PointerEnterEvent event)? onHoverStart;
  final void Function(PointerExitEvent event)? onExit;
  final void Function(double val)? onHorizontalDrag;
  final void Function()? onDragStart;
  final void Function()? onDragEnd;

  @override
  _VideoGestureDetectorState createState() => _VideoGestureDetectorState();
}

class _VideoGestureDetectorState extends State<_VideoGestureDetector> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;
  final _flCtr = Get.find<FlVideoController>();

  @override
  Widget build(BuildContext context) {
    double relative = 0;
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final tapPos = box?.globalToLocal(globalPosition) ?? Offset.zero;
      relative = tapPos.dx / ((box?.size.width) ?? 0);
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return MouseRegion(
      onEnter: widget.onHoverStart,
      onHover: (event) => _flCtr.onOverlayHover(),
      onExit: widget.onExit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: widget.child,
        onHorizontalDragStart: (DragStartDetails details) {
          if (!controller.value.isInitialized) {
            return;
          }
          _controllerWasPlaying = controller.value.isPlaying;
          if (widget.onDragStart != null) widget.onDragStart!();
          if (_controllerWasPlaying) {
            controller.pause();
          }
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          if (!controller.value.isInitialized) {
            return;
          }
          seekToRelativePosition(details.globalPosition);
          if (widget.onHorizontalDrag != null) {
            widget.onHorizontalDrag!(relative);
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (widget.onDragEnd != null) widget.onDragEnd!();
          if (_controllerWasPlaying) {
            controller.play();
          }
        },
        onTapDown: (TapDownDetails details) {
          if (!controller.value.isInitialized) {
            return;
          }
          if (widget.onHorizontalDrag != null) {
            widget.onHorizontalDrag!(relative);
          }

          seekToRelativePosition(details.globalPosition);
        },
      ),
    );
  }
}
