import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';

class InputTresholds extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double step;
  final ValueChanged<double>? onChanged;

  const InputTresholds({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.step = 1,
    this.onChanged,
  });

  @override
  _InputTresholdsState createState() => _InputTresholdsState();
}

class _InputTresholdsState extends State<InputTresholds> {
  late double _value;
  bool _isPressedLeft = false;
  bool _isPressedRight = false;

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

    // Gunakan TextPainter untuk menghitung panjang teks dan menyesuaikan lebar
    String textValue = _value % 1 == 0 ? "${_value.toInt()}" : "${_value.toStringAsFixed(1)}";
    final textPainter = TextPainter(
      text: TextSpan(text: textValue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColorConstant.primary)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    double minInputWidth = 20.0;
    double maxInputWidth = 40.0;

    double inputWidth = textPainter.size.width < minInputWidth ? minInputWidth : (textPainter.size.width > maxInputWidth ? maxInputWidth : textPainter.size.width);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol panah kiri (kurangi nilai)
        GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isPressedLeft = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressedLeft = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _isPressedLeft = false;
            });
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isPressedLeft ? ColorConstant.primary.withAlpha(50) : (isMin ? Colors.grey : Colors.white), // Warna biru saat ditekan
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: isMin ? Colors.black38 : Colors.black, size: 16),
              onPressed: isMin ? null : _decreaseValue,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            ),
          ),
        ),

        // Tampilan nilai
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: inputWidth,
            child: Text(
              textValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorConstant.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Tombol panah kanan (tambah nilai)
        GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isPressedRight = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressedRight = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _isPressedRight = false;
            });
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isPressedRight ? ColorConstant.primary.withAlpha(50) : (isMax ? Colors.grey : Colors.white), // Warna biru saat ditekan
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: isMax ? Colors.black38 : Colors.black, size: 16),
              onPressed: isMax ? null : _increaseValue,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            ),
          ),
        ),
      ],
    );
  }
}
