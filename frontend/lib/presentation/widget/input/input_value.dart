import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';

class InputValue extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double step;
  final String unit;
  final ValueChanged<double>? onChanged;

  const InputValue({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.step = 1,
    this.unit = "",
    this.onChanged,
  });

  @override
  _InputValueState createState() => _InputValueState();
}

class _InputValueState extends State<InputValue> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _decreaseValue() {
    if (_value - widget.step >= widget.minValue) {
      setState(() {
        _value -= widget.step;
        widget.onChanged?.call(_value);
      });
    }
  }

  void _increaseValue() {
    if (_value + widget.step <= widget.maxValue) {
      setState(() {
        _value += widget.step;
        widget.onChanged?.call(_value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMin = _value <= widget.minValue;
    bool isMax = _value >= widget.maxValue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol panah kiri (kurangi nilai)
        GestureDetector(
          onTapDown: (_) => setState(() {}),
          onTapUp: (_) => setState(() {}),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isMin ? Colors.grey : Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: isMin ? Colors.black38 : Colors.black, size: 16),
              onPressed: isMin ? null : _decreaseValue,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            ),
          ),
        ),

        // Tampilan nilai
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            _value % 1 == 0 ? "${_value.toInt()} ${widget.unit}" : "${_value.toStringAsFixed(1)} ${widget.unit}", // Format angka
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorConstant.primary,
            ),
          ),
        ),

        // Tombol panah kanan (tambah nilai)
        GestureDetector(
          onTapDown: (_) => setState(() {}),
          onTapUp: (_) => setState(() {}),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isMax ? Colors.grey : Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: isMax ? Colors.black38 : Colors.black, size: 16),
              onPressed: isMax ? null : _increaseValue,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            ),
          ),
        ),
      ],
    );
  }
}
