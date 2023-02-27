import 'package:flutter/material.dart';

class MaterialIconButton extends StatelessWidget {
  const MaterialIconButton({
    required this.child,
    required this.toolTipMesg,
    super.key,
    this.color,
    this.radius = 12,
    this.onPressed,
    this.onHover,
    this.onTapDown,
  });

  final Color? color;
  final Widget child;
  final double radius;
  final String toolTipMesg;
  final void Function()? onPressed;
  final void Function(bool)? onHover;
  final void Function(TapDownDetails details)? onTapDown;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: Tooltip(
        message: toolTipMesg,
        // textStyle: TextStyle(fontSize: 0.01),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius * 4),
          onHover: onHover,
          onTap: onPressed,
          onTapDown: onTapDown,
          child: Padding(
            padding: EdgeInsets.all(radius),
            child: IconTheme(
              data: IconThemeData(color: color, size: 24),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
