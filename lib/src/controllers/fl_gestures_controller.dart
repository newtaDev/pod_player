part of './fl_video_controller.dart';

class _FlGesturesController extends _FlVimeoVideoController {
  //double tap
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  int leftDoubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  Timer? hoverOverlayTimer;

  ///*handle double tap

  void onLeftDoubleTap() {
    isShowOverlay(true);
    leftDoubleTapTimer?.cancel();
    isLeftDbTapIconVisible = true;
    updateLeftTapDuration(leftDoubleTapduration += 10);
    seekBackward(const Duration(seconds: 10));
    leftDoubleTapTimer = Timer(const Duration(milliseconds: 1500), () {
      isLeftDbTapIconVisible = false;
      updateLeftTapDuration(0);
      leftDoubleTapTimer?.cancel();
      isShowOverlay(false);
    });
  }

  void onRightDoubleTap() {
    isShowOverlay(true);
    rightDoubleTapTimer?.cancel();
    isRightDbTapIconVisible = true;
    updateRightTapDuration(rightDubleTapduration += 10);
    seekForward(const Duration(seconds: 10));
    rightDoubleTapTimer = Timer(const Duration(milliseconds: 1500), () {
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      isShowOverlay(false);
    });
  }

  void onOverlayHover() {
    if (kIsWeb) {
      hoverOverlayTimer?.cancel();
      isShowOverlay(true);
      hoverOverlayTimer = Timer(
        const Duration(seconds: 4),
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
  }

  void updateRightTapDuration(int val) {
    rightDubleTapduration = val;
    update(['double-tap']);
  }
}