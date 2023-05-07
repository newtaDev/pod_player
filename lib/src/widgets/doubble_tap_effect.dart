import 'package:flutter/material.dart';

class DoubleTapRippleEffect extends StatefulWidget {
  /// child widget [child]
  final Widget? child;

  /// Helps to wrap child widget inside a parent widget
  final Widget Function(Widget parentWidget, double curveRadius)? wrapper;

  /// touch effect color of widget [rippleColor]
  final Color? rippleColor;

  /// TouchRippleEffect widget background color [backgroundColor]
  final Color? backgroundColor;

  /// if you have border of child widget then you should apply [borderRadius]
  final BorderRadius? borderRadius;

  /// animation duration of touch effect. [rippleDuration]
  final Duration? rippleDuration;

  /// duration to stay the frame. [rippleEndingDuraiton]
  final Duration? rippleEndingDuraiton;

  /// user click or tap handle [onDoubleTap].
  final void Function()? onDoubleTap;

  /// TouchRippleEffect widget width size [width]
  final double? width;

  /// TouchRippleEffect widget height size [height]
  final double? height;

  const DoubleTapRippleEffect({
    Key? key,
    this.child,
    this.wrapper,
    this.rippleColor,
    this.backgroundColor,
    this.borderRadius,
    this.rippleDuration,
    this.rippleEndingDuraiton,
    this.onDoubleTap,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<DoubleTapRippleEffect> createState() => _DoubleTapRippleEffectState();
}

class _DoubleTapRippleEffectState extends State<DoubleTapRippleEffect>
    with SingleTickerProviderStateMixin {
  // by default offset will be 0,0
  // it will be set when user tap on widget
  Offset _tapOffset = Offset.zero;

  // globalKey variable decleared
  final GlobalKey _globalKey = GlobalKey();

  // animation global variable decleared and
  // type cast is double
  late Animation<double> _anim;

  // animation controller global variable decleared
  late AnimationController _animationController;

  /// width of user child widget
  double _mWidth = 0;

  // height of user child widget
  double _mHeight = 0;

  // tween animation global variable decleared and
  // type cast is double
  late Tween<double> _tweenAnim;

  // animation count of Tween anim.
  // by default value is 0.
  double _animRadiusValue = 0;

  @override
  void initState() {
    super.initState();
    // animation controller initialized
    _animationController = AnimationController(
      vsync: this,
      duration: widget.rippleDuration ?? const Duration(milliseconds: 300),
    );
    // animation controller listener added or iitialized
    _animationController.addListener(_update);
  }

  // update animation when started

  void _update() {
    setState(() {
      // [_anim.value] setting to [_animRadiusValue] global variable
      _animRadiusValue = _anim.value;
    });
    // animation status function calling
    _animStatus();
  }

  // checking animation status is completed
  void _animStatus() {
    if (_anim.status == AnimationStatus.completed) {
      Future.delayed(
        widget.rippleEndingDuraiton ?? const Duration(milliseconds: 600),
      ).then((value) {
        setState(() {
          _animRadiusValue = 0;
        });
        // stoping animation after completed
        _animationController.stop();
      });
    }
  }

  @override
  void dispose() {
    // disposing [_animationController] when parent exist of close
    _animationController.dispose();
    super.dispose();
  }

  // animation initialize reset and start
  void _animate() {
    final width = widget.width ?? _mWidth;
    final height = widget.height ?? _mHeight;
    // [Tween] animation initialize to global variable
    _tweenAnim = Tween(begin: 0, end: (width + height) / 1.5);

    // adding [_animationController] to [_tweenanim] to animate
    _anim = _tweenAnim.animate(_animationController);

    _animationController
      // resetting [_animationController] before start
      ..reset()
      // starting [_animationController] to start animation
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final curveRadius = (_mWidth + _mHeight) / 2;
    if (widget.wrapper != null) return widget.wrapper!(_builder(), curveRadius);
    return _builder();
  }

  Widget _builder() {
    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      onDoubleTapDown: (details) {
        // getting tap [localPostion] of user
        final lp = details.localPosition;
        setState(() {
          /// setting [Offset] of user tap to [_tapOffset] global variable
          _tapOffset = Offset(lp.dx, lp.dy);
        });

        // getting [size] of child widget
        final size = _globalKey.currentContext!.size!;

        // child widget [width] initialize to [_width] global variable
        _mWidth = size.width;

        // child widget [height] initialize to [_height] global variable
        _mHeight = size.height;

        // starting animation
        _animate();
      },
      child: Container(
        width: widget.width,
        height: widget.height,

        // added globalKey for getting child widget size
        key: _globalKey,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          // when color == null then color will be transpatent otherwise color will be backgroundColor
          color: widget.backgroundColor ?? Colors.transparent,

          // boderRadius of container if user passed
          borderRadius: widget.borderRadius,
        ),
        child: Stack(
          children: [
            // added child widget of user
            widget.child!,
            Opacity(
              opacity: 0.3,
              child: CustomPaint(
                // ripplePainter is CustomPainer for circular ripple draw
                painter: RipplePainer(
                  offset: _tapOffset,
                  circleRadius: _animRadiusValue,
                  fillColor: widget.rippleColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RipplePainer extends CustomPainter {
  // user tap locations [Offset]
  final Offset? offset;

  // radius of circle which will be ripple color size [circleRadius]
  final double? circleRadius;

  // fill color of ripple [fillColor]
  final Color? fillColor;
  RipplePainer({this.offset, this.circleRadius, this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    // throw an [rippleColor == null error] if ripple color is null
    final paint = Paint()
      ..color = fillColor == null
          ? throw Exception('rippleColor of TouchRippleEffect == null')
          : fillColor!
      ..isAntiAlias = true;

    // drawing canvas based on user click offset,radius and paint
    canvas.drawCircle(offset!, circleRadius!, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
