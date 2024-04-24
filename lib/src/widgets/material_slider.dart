import 'package:flutter/material.dart';

class MaterialSlider extends StatefulWidget {
  final bool isVisible;

  const MaterialSlider({
    required this.isVisible,
    required this.onChanged,
    required this.initialValue,
    this.activeTrackColor = Colors.white,
    this.inactiveTrackColor = Colors.white24,
    this.thumbColor = Colors.white,
    super.key,
  });

  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;

  final void Function(double) onChanged;
  final double initialValue;

  @override
  State<MaterialSlider> createState() => _MaterialSliderState();
}

class _MaterialSliderState extends State<MaterialSlider> {
  double _value = 0;

  void _initValue() {
    if (mounted) setState(() => _value = widget.initialValue);
  }

  void _onChanged(double newValue) {
    if (mounted) setState(() => _value = newValue);
    widget.onChanged(newValue);
  }

  @override
  void initState() {
    super.initState();
    _initValue();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox();

    return Material(
      type: MaterialType.transparency,
      color: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbColor: widget.thumbColor,
            activeTrackColor: widget.activeTrackColor,
            inactiveTrackColor: widget.inactiveTrackColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            trackShape: const RectangularSliderTrackShape(),
            trackHeight: 3,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: SizedBox(
            width: 100,
            child: Slider(value: _value, onChanged: _onChanged),
          ),
        ),
      ),
    );
  }
}
