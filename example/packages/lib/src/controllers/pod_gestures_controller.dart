part of 'pod_getx_video_controller.dart';

class _PodGesturesController extends _PodVideoQualityController {
  //double tap
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  int leftDoubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  Timer? hoverOverlayTimer;

  ///*handle double tap

  void onLeftDoubleTap({int? seconds}) {
    isShowOverlay(true);
    leftDoubleTapTimer?.cancel();
    rightDoubleTapTimer?.cancel();

    isRightDbTapIconVisible = false;
    isLeftDbTapIconVisible = true;
    updateLeftTapDuration(
      leftDoubleTapduration += seconds ?? doubleTapForwardSeconds,
    );
    seekBackward(Duration(seconds: seconds ?? doubleTapForwardSeconds));
    update(['double-tap-left']);
    leftDoubleTapTimer = Timer(const Duration(milliseconds: 500), () {
      isLeftDbTapIconVisible = false;
      updateLeftTapDuration(0);
      leftDoubleTapTimer?.cancel();
      if (isvideoPlaying) {
        playVideo(true);
      }
      isShowOverlay(false);
    });
  }

  void onRightDoubleTap({int? seconds}) {
    isShowOverlay(true);
    rightDoubleTapTimer?.cancel();
    leftDoubleTapTimer?.cancel();

    isLeftDbTapIconVisible = false;
    isRightDbTapIconVisible = true;
    updateRightTapDuration(
      rightDubleTapduration += seconds ?? doubleTapForwardSeconds,
    );
    seekForward(Duration(seconds: seconds ?? doubleTapForwardSeconds));
    update(['double-tap-right']);
    rightDoubleTapTimer = Timer(const Duration(milliseconds: 500), () {
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      if (isvideoPlaying) {
        playVideo(true);
      }
      isShowOverlay(false);
    });
  }

  void onOverlayHover() {
    if (kIsWeb) {
      hoverOverlayTimer?.cancel();
      isShowOverlay(true);
      hoverOverlayTimer = Timer(
        const Duration(seconds: 3),
        () => isShowOverlay(false),
      );
    }
  }

  void onOverlayHoverExit() {
    if (kIsWeb) {
      isShowOverlay(false);
    }
  }

  ///update doubletap durations
  void updateLeftTapDuration(int val) {
    leftDoubleTapduration = val;
    update(['double-tap']);
    update(['update-all']);
  }

  void updateRightTapDuration(int val) {
    rightDubleTapduration = val;
    update(['double-tap']);
    update(['update-all']);
  }
}
