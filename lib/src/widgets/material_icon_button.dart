
import 'package:flutter/material.dart';

class MaterialIconButton extends StatelessWidget {
  const MaterialIconButton({
    Key? key,
    this.color,
    required this.child,
    this.radius = 12,
    this.onPressed, this.onHover,
  }) : super(key: key);

  final Color? color;
  final Widget child;
  final double radius;
  final void Function()? onPressed;
  final void Function(bool)? onHover;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius * 4),
        onHover: onHover,
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(radius),
          child: IconTheme(
            data: IconThemeData(color: color, size: 24),
            child: child,
          ),
        ),
      ),
    );
  }
}