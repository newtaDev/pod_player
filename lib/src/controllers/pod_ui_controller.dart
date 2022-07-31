part of 'pod_getx_video_controller.dart';

class _PodUiController extends _PodBaseController {
  bool alwaysShowProgressBar = true;
  PodProgressBarConfig podProgressBarConfig = const PodProgressBarConfig();
  Widget Function(OverLayOptions options)? overlayBuilder;
  Widget? videoTitle;
  DecorationImage? videoThumbnail;

  /// Callback when fullscreen mode changes
  Future<void> Function(bool isFullScreen)? onToggleFullScreen;

  /// Builder for custom loading widget
  WidgetBuilder? onLoading;

  ///video player labels
  PodPlayerLabels podPlayerLabels = const PodPlayerLabels();
}
