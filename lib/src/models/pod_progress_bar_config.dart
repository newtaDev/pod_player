import 'package:flutter/material.dart';

typedef GetProgressBarBackgroundPaint = Paint Function({
  double? width,
  double? height,
  double? circleHandlerRadius,
});

typedef GetProgressBarPlayedPaint = Paint Function({
  double? width,
  double? height,
  double? playedPart,
  double? circleHandlerRadius,
});

typedef GetProgressBarBufferedPaint = Paint Function({
  double? width,
  double? height,
  double? playedPart,
  double? circleHandlerRadius,
  double? bufferedStart,
  double? bufferedEnd,
});

typedef GetProgressBarHandlePaint = Paint Function({
  double? width,
  double? height,
  double? playedPart,
  double? circleHandlerRadius,
});

class PodProgressBarConfig {
  const PodProgressBarConfig({
    this.playingBarColor = Colors.red,
    this.bufferedBarColor = const Color.fromRGBO(255, 255, 255, 0.38),
    this.circleHandlerColor = Colors.red,
    this.alwaysVisibleCircleHandler = false,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.24),
    this.getPlayedPaint,
    this.getBufferedPaint,
    this.getCircleHandlerPaint,
    this.getBackgroundPaint,
    this.height = 3.6,
    this.padding = EdgeInsets.zero,
    this.circleHandlerRadius = 8,
    this.curveRadius = 4,
  });

  /// Color for played area, not applied if [getPlayedPaint] is provided.
  final Color playingBarColor;

  /// Color for buffered area, not applied if [getBufferedPaint] is provided.
  final Color bufferedBarColor;

  /// Color for handle, not applied if [getCircleHandlerPaint] is provided.
  final Color circleHandlerColor;

  final bool alwaysVisibleCircleHandler;

  /// Color for background area, not applied if [getBackgroundPaint] is provided.
  final Color backgroundColor;

  /// Paint for played area.
  final GetProgressBarPlayedPaint? getPlayedPaint;

  /// Paint for buffered area.
  final GetProgressBarBufferedPaint? getBufferedPaint;

  /// Paint for handle.
  final GetProgressBarHandlePaint? getCircleHandlerPaint;

  /// Paint for background area.
  final GetProgressBarBackgroundPaint? getBackgroundPaint;

  /// Height of the progress bar.
  final double height;

  /// Padding for the progress bar.
  /// Padding area is included in the [GestureDetector].
  final EdgeInsetsGeometry padding;

  /// Handle radius.
  /// Should be bigger then [height] so that handle is visible.
  /// 0.0 will hide the handle.
  final double circleHandlerRadius;

  /// Radius to curve the ends of the bar.
  final double curveRadius;

  PodProgressBarConfig copyWith({
    Color? playingBarColor,
    Color? bufferedBarColor,
    Color? circleHandlerColor,
    bool? alwaysVisibleCircleHandler,
    Color? backgroundColor,
    GetProgressBarPlayedPaint? getPlayedPaint,
    GetProgressBarBufferedPaint? getBufferedPaint,
    GetProgressBarHandlePaint? getCircleHandlerPaint,
    GetProgressBarBackgroundPaint? getBackgroundPaint,
    double? height,
    EdgeInsetsGeometry? padding,
    double? circleHandlerRadius,
    double? curveRadius,
  }) {
    return PodProgressBarConfig(
      playingBarColor: playingBarColor ?? this.playingBarColor,
      bufferedBarColor: bufferedBarColor ?? this.bufferedBarColor,
      circleHandlerColor: circleHandlerColor ?? this.circleHandlerColor,
      alwaysVisibleCircleHandler:
          alwaysVisibleCircleHandler ?? this.alwaysVisibleCircleHandler,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      getPlayedPaint: getPlayedPaint ?? this.getPlayedPaint,
      getBufferedPaint: getBufferedPaint ?? this.getBufferedPaint,
      getCircleHandlerPaint:
          getCircleHandlerPaint ?? this.getCircleHandlerPaint,
      getBackgroundPaint: getBackgroundPaint ?? this.getBackgroundPaint,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      circleHandlerRadius: circleHandlerRadius ?? this.circleHandlerRadius,
      curveRadius: curveRadius ?? this.curveRadius,
    );
  }
}
