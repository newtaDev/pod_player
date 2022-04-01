import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:video_player/video_player.dart';

import '../controllers/pod_getx_video_controller.dart';
import '../models/pod_progress_bar_config.dart';

/// Renders progress bar for the video using custom paint.
class PodProgressBar extends StatefulWidget {
  const PodProgressBar({
    Key? key,
    PodProgressBarConfig? podProgressBarConfig,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.alignment = Alignment.center,
    required this.tag,
  })  : podProgressBarConfig =
            podProgressBarConfig ?? const PodProgressBarConfig(),
        super(key: key);

  final PodProgressBarConfig podProgressBarConfig;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;
  final Alignment alignment;
  final String tag;

  @override
  State<PodProgressBar> createState() => _PodProgressBarState();
}

class _PodProgressBarState extends State<PodProgressBar> {
  late final _podCtr = Get.find<PodGetXVideoController>(tag: widget.tag);
  late VideoPlayerValue? videoPlayerValue = _podCtr.videoCtr?.value;
  bool _controllerWasPlaying = false;

  void seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position =
          (videoPlayerValue?.duration ?? Duration.zero) * relative;
      _podCtr.seekTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerValue == null) return const SizedBox();

    return GetBuilder<PodGetXVideoController>(
      tag: widget.tag,
      id: 'video-progress',
      builder: (_podCtr) {
        videoPlayerValue = _podCtr.videoCtr?.value;
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
                    _podCtr.videoCtr?.value.isPlaying ?? false;
                if (_controllerWasPlaying) {
                  _podCtr.videoCtr?.pause();
                }

                if (widget.onDragStart != null) {
                  widget.onDragStart?.call();
                }
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                _podCtr.isShowOverlay(true);
                seekToRelativePosition(details.globalPosition);

                widget.onDragUpdate?.call();
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (_controllerWasPlaying) {
                  _podCtr.videoCtr?.play();
                }
                _podCtr.toggleVideoOverlay();

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
        padding: widget.podProgressBarConfig.padding,
        child: SizedBox(
          width: size.maxWidth,
          height: widget.podProgressBarConfig.circleHandlerRadius,
          child: Align(
            alignment: widget.alignment,
            child: GetBuilder<PodGetXVideoController>(
              tag: widget.tag,
              id: 'overlay',
              builder: (_podCtr) => CustomPaint(
                painter: _ProgressBarPainter(
                  videoPlayerValue!,
                  podProgressBarConfig: widget.podProgressBarConfig.copyWith(
                    circleHandlerRadius: _podCtr.isOverlayVisible ||
                            widget
                                .podProgressBarConfig.alwaysVisibleCircleHandler
                        ? widget.podProgressBarConfig.circleHandlerRadius
                        : 0,
                  ),
                ),
                size: Size(
                  double.maxFinite,
                  widget.podProgressBarConfig.height,
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
  _ProgressBarPainter(this.value, {this.podProgressBarConfig});

  VideoPlayerValue value;
  PodProgressBarConfig? podProgressBarConfig;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double height = podProgressBarConfig!.height;
    final double width = size.width;
    final double curveRadius = podProgressBarConfig!.curveRadius;
    final double circleHandlerRadius =
        podProgressBarConfig!.circleHandlerRadius;
    final Paint backgroundPaint =
        podProgressBarConfig!.getBackgroundPaint != null
            ? podProgressBarConfig!.getBackgroundPaint!(
                width: width,
                height: height,
                circleHandlerRadius: circleHandlerRadius,
              )
            : Paint()
          ..color = podProgressBarConfig!.backgroundColor;

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

      final Paint bufferedPaint = podProgressBarConfig!.getBufferedPaint != null
          ? podProgressBarConfig!.getBufferedPaint!(
              width: width,
              height: height,
              playedPart: playedPart,
              circleHandlerRadius: circleHandlerRadius,
              bufferedStart: start,
              bufferedEnd: end,
            )
          : Paint()
        ..color = podProgressBarConfig!.bufferedBarColor;

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

    final Paint playedPaint = podProgressBarConfig!.getPlayedPaint != null
        ? podProgressBarConfig!.getPlayedPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            circleHandlerRadius: circleHandlerRadius,
          )
        : Paint()
      ..color = podProgressBarConfig!.playingBarColor;
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

    final Paint handlePaint =
        podProgressBarConfig!.getCircleHandlerPaint != null
            ? podProgressBarConfig!.getCircleHandlerPaint!(
                width: width,
                height: height,
                playedPart: playedPart,
                circleHandlerRadius: circleHandlerRadius,
              )
            : Paint()
          ..color = podProgressBarConfig!.circleHandlerColor;

    canvas.drawCircle(
      Offset(playedPart, height / 2),
      circleHandlerRadius,
      handlePaint,
    );
  }
}
