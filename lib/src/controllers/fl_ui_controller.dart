part of 'fl_getx_video_controller.dart';

class _FlUiController extends _FlGesturesController {
  bool alwaysShowProgressBar = true;
  FlProgressBarConfig flProgressBarConfig = const FlProgressBarConfig();
  Widget Function(OverLayOptions options)? overlayBuilder;
  Widget? videoTitle;
}
