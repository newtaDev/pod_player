import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:video_player/video_player.dart';

import '../controllers/pod_getx_video_controller.dart';
import '../models/pod_progress_bar_config.dart';

/// Renders progress bar for the video using custom paint.
class FlVideoProgressBar extends StatefulWidget {
  const FlVideoProgressBar({
    Key? key,
    FlProgressBarConfig? flProgressBarConfig,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.alignment = Alignment.center,
    required this.tag,
  })  : flProgressBarConfig =
            flProgressBarConfig ?? const FlProgressBarConfig(),
        super(key: key);

  final FlProgressBarConfig flProgressBarConfig;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;
  final Alignment alignment;
  final String tag;

  @override
  State<FlVideoProgressBar> createState() => _FlVideoProgressBarState();
}

class _FlVideoProgressBarState extends State<FlVideoProgressBar> {
  late final _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);
  late VideoPlayerValue? videoPlayerValue = _flCtr.videoCtr?.value;
  bool _controllerWasPlaying = false;

  void seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position =
          (videoPlayerValue?.duration ?? Duration.zero) * relative;
      _flCtr.seekTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerValue == null) return const SizedBox();

    return GetBuilder<FlGetXVideoController>(
      tag: widget.tag,
      id: 'video-progress',
      builder: (_flCtr) {
        videoPlayerValue = _flCtr.videoCtr?.value;
        return LayoutBuilder(
          builder: (context, size) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: _progressBar(size),
              onHorizontalDragStart: (DragStartDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                _controllerWasPlaying =
                    _flCtr.videoCtr?.value.isPlaying ?? false;
                if (_controllerWasPlaying) {
                  _flCtr.videoCtr?.pause();
                }

                if (widget.onDragStart != null) {
                  widget.onDragStart?.call();
                }
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                _flCtr.isShowOverlay(true);
                seekToRelativePosition(details.globalPosition);

                widget.onDragUpdate?.call();
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (_controllerWasPlaying) {
                  _flCtr.videoCtr?.play();
                }
                _flCtr.toggleVideoOverlay();

                if (widget.onDragEnd != null) {
                  widget.onDragEnd?.call();
                }
              },
              onTapDown: (TapDownDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                seekToRelativePosition(details.globalPosition);
              },
            );
          },
        );
      },
    );
  }

  MouseRegion _progressBar(BoxConstraints size) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: widget.flProgressBarConfig.padding,
        child: SizedBox(
          width: size.maxWidth,
          height: widget.flProgressBarConfig.circleHandlerRadius,
          child: Align(
            alignment: widget.alignment,
            child: GetBuilder<FlGetXVideoController>(
              tag: widget.tag,
              id: 'overlay',
              builder: (_fl) => CustomPaint(
                painter: _ProgressBarPainter(
                  videoPlayerValue!,
                  flProgressBarConfig: widget.flProgressBarConfig.copyWith(
                    circleHandlerRadius: _fl.isOverlayVisible ||
                            widget
                                .flProgressBarConfig.alwaysVisibleCircleHandler
                        ? widget.flProgressBarConfig.circleHandlerRadius
                        : 0,
                  ),
                ),
                size: Size(
                  double.maxFinite,
                  widget.flProgressBarConfig.height,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, {this.flProgressBarConfig});

  VideoPlayerValue value;
  FlProgressBarConfig? flProgressBarConfig;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double height = flProgressBarConfig!.height;
    final double width = size.width;
    final double curveRadius = flProgressBarConfig!.curveRadius;
    final double circleHandlerRadius = flProgressBarConfig!.circleHandlerRadius;
    final Paint backgroundPaint =
        flProgressBarConfig!.getBackgroundPaint != null
            ? flProgressBarConfig!.getBackgroundPaint!(
                width: width,
                height: height,
                circleHandlerRadius: circleHandlerRadius,
              )
            : Paint()
          ..color = flProgressBarConfig!.backgroundColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(width, height),
        ),
        Radius.circular(curveRadius),
      ),
      backgroundPaint,
    );
    if (value.isInitialized == false) {
      return;
    }

    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? width : playedPartPercent * width;

    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * width;
      final double end = range.endFraction(value.duration) * width;

      final Paint bufferedPaint = flProgressBarConfig!.getBufferedPaint != null
          ? flProgressBarConfig!.getBufferedPaint!(
              width: width,
              height: height,
              playedPart: playedPart,
              circleHandlerRadius: circleHandlerRadius,
              bufferedStart: start,
              bufferedEnd: end,
            )
          : Paint()
        ..color = flProgressBarConfig!.bufferedBarColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, 0),
            Offset(end, height),
          ),
          Radius.circular(curveRadius),
        ),
        bufferedPaint,
      );
    }

    final Paint playedPaint = flProgressBarConfig!.getPlayedPaint != null
        ? flProgressBarConfig!.getPlayedPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            circleHandlerRadius: circleHandlerRadius,
          )
        : Paint()
      ..color = flProgressBarConfig!.playingBarColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(playedPart, height),
        ),
        Radius.circular(curveRadius),
      ),
      playedPaint,
    );

    final Paint handlePaint = flProgressBarConfig!.getCircleHandlerPaint != null
        ? flProgressBarConfig!.getCircleHandlerPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            circleHandlerRadius: circleHandlerRadius,
          )
        : Paint()
      ..color = flProgressBarConfig!.circleHandlerColor;

    canvas.drawCircle(
      Offset(playedPart, height / 2),
      circleHandlerRadius,
      handlePaint,
    );
  }
}

//!old
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';

// import '../controllers/fl_getx_video_controller.dart';
// import '../utils/fl_enums.dart';

// class FlVideoProgressBar extends StatefulWidget {
//   const FlVideoProgressBar({
//     Key? key,
//     this.colors,
//     required this.allowGestures,
//     this.height = 20,
//     this.padding = EdgeInsets.zero,
//     required this.tag,
//   }) : super(key: key);

//   final VideoProgressColors? colors;

//   final bool allowGestures;

//   final double height;

//   final EdgeInsets padding;
//   final String tag;

//   @override
//   _FlVideoProgressBarState createState() => _FlVideoProgressBarState();
// }

// class _FlVideoProgressBarState extends State<FlVideoProgressBar> {
//   VideoProgressColors get colors =>
//       widget.colors ??
//       VideoProgressColors(
//         backgroundColor: Colors.grey.withOpacity(0.5),
//         bufferedColor: Colors.grey[500]!,
//       );

//   double? relativeVal;
//   late double relativeWidth;
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<FlGetXVideoController>(
//       tag: widget.tag,
//       id: 'video-progress',
//       builder: (_flCtr) {
//         Widget progressIndicator;
//         if (_flCtr.videoCtr!.value.isInitialized) {
//           final int duration = _flCtr.videoCtr!.value.duration.inMilliseconds;
//           final int position = _flCtr.videoCtr!.value.position.inMilliseconds;

//           int maxBuffering = 0;
//           for (final DurationRange range in _flCtr.videoCtr!.value.buffered) {
//             final int end = range.end.inMilliseconds;
//             if (end > maxBuffering) {
//               maxBuffering = end;
//             }
//           }
//           relativeVal = position / duration;
//           final double barHeight = _flCtr.isOverlayVisible
//               ? 20
//               : isHovered
//                   ? 20
//                   : widget.height;
//           const alignmentLoc = Alignment.bottomLeft;
//           progressIndicator = _progressWidget(
//             alignmentLoc,
//             barHeight,
//             maxBuffering,
//             duration,
//             position,
//           );
//         } else {
//           progressIndicator = LinearProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
//             backgroundColor: colors.backgroundColor,
//           );
//         }
//         if (widget.allowGestures) {
//           return Padding(
//             padding: widget.padding,
//             child: _VideoProgressGestureDetector(
//               tag: widget.tag,
//               controller: _flCtr.videoCtr!,
//               onHoverStart: _onHoverStart,
//               onExit: _onExit,
//               onHorizontalDrag: onHrDrag,
//               onDragStart: () => isHovered = true,
//               onDragEnd: () => isHovered = false,
//               child: progressIndicator,
//             ),
//           );
//         } else {
//           return progressIndicator;
//         }
//       },
//     );
//   }

//   void onHrDrag(double val) {
//     final _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);

//     relativeVal = val;
//     if (kIsWeb) _flCtr.isShowOverlay(true);
//   }

//   Stack _progressWidget(
//     Alignment alignmentLoc,
//     double barHeight,
//     int maxBuffering,
//     int duration,
//     int position,
//   ) {
//     final _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);

//     return Stack(
//       alignment: alignmentLoc,
//       fit: StackFit.passthrough,
//       children: <Widget>[
//         SizedBox(
//           height: barHeight,
//           child: Align(
//             alignment: alignmentLoc,
//             child: LinearProgressIndicator(
//               value: maxBuffering / duration,
//               valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
//               backgroundColor: colors.backgroundColor,
//             ),
//           ),
//         ),
//         _VideoProgressBar(
//             position: position,
//             duration: duration,
//             relativeVal: relativeVal,
//             height: widget.height,
//             isHovered: isHovered,
//             showThumbHandler: isHovered ||
//                 _flCtr.isOverlayVisible ||
//                 _flCtr.flVideoState == FlVideoState.paused,
//             colors: colors,
//             alignmentLoc: alignmentLoc),
//       ],
//     );
//   }

//   void _onHoverStart(event) {
//     if (kIsWeb) isHovered = true;
//   }

//   void _onExit(event) {
//     if (kIsWeb) {
//       if (isHovered == true) {
//         if (mounted) setState(() => isHovered = false);
//       }
//     }
//   }
// }

// class _VideoProgressBar extends StatelessWidget {
//   final double? relativeVal;
//   final int position;
//   final int duration;
//   final double height;
//   final bool isHovered;
//   final VideoProgressColors colors;
//   final Alignment alignmentLoc;
//   final bool showThumbHandler;
//   const _VideoProgressBar({
//     Key? key,
//     this.relativeVal,
//     required this.position,
//     required this.duration,
//     required this.height,
//     required this.isHovered,
//     required this.colors,
//     required this.alignmentLoc,
//     required this.showThumbHandler,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     ///Progress bar height
//     final double barHeight = showThumbHandler ? 20 : height;

//     ///Progress bar width
//     double relativeWidth;

//     ///Progress circle config
//     final double _progresscircleHeight = showThumbHandler ? 20 : 0;
//     final double _progresscircleWidth = showThumbHandler ? 15 : 0;
//     final List<BoxShadow> _progressCircleShadow = showThumbHandler && isHovered
//         ? [
//             BoxShadow(
//               spreadRadius: 4,
//               color: colors.playedColor.withOpacity(0.3),
//             )
//           ]
//         : [];
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         relativeWidth =
//             constraints.maxWidth * (relativeVal ?? (position / duration));
//         return SizedBox(
//           height: barHeight,
//           width: relativeWidth,
//           child: Center(
//             child: Stack(
//               children: [
//                 Align(
//                   alignment: alignmentLoc,
//                   child: ColoredBox(
//                     color: colors.playedColor,
//                     child: SizedBox(
//                       height: isHovered ? 6 : 5,
//                       width: relativeWidth,
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomRight,
//                   child: AnimatedOpacity(
//                     duration: const Duration(milliseconds: 200),
//                     opacity: showThumbHandler ? 1 : 0,
//                     child: SizedBox(
//                       height: _progresscircleHeight,
//                       width: _progresscircleWidth,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 100),
//                         alignment: Alignment.center,
//                         transform: Matrix4.translationValues(
//                             0, _progresscircleHeight != 0 ? 7 : 0, 0),
//                         // ..translate(
//                         // 0,
//                         // _progresscircleHeight != 0 ? 7 : 0,
//                         // ),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: colors.playedColor,
//                           boxShadow: _progressCircleShadow,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _VideoProgressGestureDetector extends StatefulWidget {
//   const _VideoProgressGestureDetector({
//     Key? key,
//     required this.tag,
//     required this.child,
//     required this.controller,
//     this.onHoverStart,
//     this.onExit,
//     this.onHorizontalDrag,
//     this.onDragStart,
//     this.onDragEnd,
//   }) : super(key: key);
//   final String tag;
//   final Widget child;
//   final VideoPlayerController controller;
//   final void Function(PointerEnterEvent event)? onHoverStart;
//   final void Function(PointerExitEvent event)? onExit;
//   final void Function(double val)? onHorizontalDrag;
//   final void Function()? onDragStart;
//   final void Function()? onDragEnd;

//   @override
//   _VideoProgressGestureDetectorState createState() =>
//       _VideoProgressGestureDetectorState();
// }

// class _VideoProgressGestureDetectorState
//     extends State<_VideoProgressGestureDetector> {
//   bool _controllerWasPlaying = false;

//   VideoPlayerController get controller => widget.controller;

//   @override
//   Widget build(BuildContext context) {
//     final _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);
//     double relative = 0;
//     void seekToRelativePosition(Offset globalPosition) {
//       final RenderBox? box = context.findRenderObject() as RenderBox?;
//       final tapPos = box?.globalToLocal(globalPosition) ?? Offset.zero;
//       relative = tapPos.dx / ((box?.size.width) ?? 0);
//       final Duration position = controller.value.duration * relative;
//       controller.seekTo(position);
//     }

//     return MouseRegion(
//       onEnter: widget.onHoverStart,
//       onHover: (event) => _flCtr.onOverlayHover(),
//       onExit: widget.onExit,
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         child: widget.child,
//         onHorizontalDragStart: (DragStartDetails details) {
//           if (!controller.value.isInitialized) {
//             return;
//           }
//           _controllerWasPlaying = controller.value.isPlaying;
//           widget.onDragStart?.call();
//           if (_controllerWasPlaying) {
//             controller.pause();
//           }
//         },
//         onHorizontalDragUpdate: (DragUpdateDetails details) {
//           if (!controller.value.isInitialized) {
//             return;
//           }
//           seekToRelativePosition(details.globalPosition);
//           if (widget.onHorizontalDrag != null) {
//             widget.onHorizontalDrag?.call(relative);
//           }
//         },
//         onHorizontalDragEnd: (DragEndDetails details) {
//           widget.onDragEnd?.call();
//           if (_controllerWasPlaying) {
//             controller.play();
//           }
//         },
//         onTapDown: (TapDownDetails details) {
//           if (!controller.value.isInitialized) {
//             return;
//           }
//           if (widget.onHorizontalDrag != null) {
//             widget.onHorizontalDrag?.call(relative);
//           }

//           seekToRelativePosition(details.globalPosition);
//         },
//       ),
//     );
//   }
// }
