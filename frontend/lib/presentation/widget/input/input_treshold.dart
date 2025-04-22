import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';

class InputTresholds extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double step; // Langkah perubahan nilai
  final String unit; // Satuan nilai (pH, ppt, NTU, gram, menit)
  final ValueChanged<double>? onChanged; // Callback untuk menangkap perubahan nilai

  const InputTresholds({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.step = 1, // Default langkah 1, bisa diubah untuk nilai desimal
    this.unit = "",
    this.onChanged,
  });

  @override
  _InputTresholdsState createState() => _InputTresholdsState();
}

class _InputTresholdsState extends State<InputTresholds> {
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
          onTapDown: (_) => setState(() {}), // Menyegarkan tampilan saat ditekan
          onTapUp: (_) => setState(() {}), // Kembali ke warna normal
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isMin ? Colors.grey : Colors.white, // Warna tombol
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: isMin ? Colors.black38 : Colors.black, size: 16),
              onPressed: isMin ? null : _decreaseValue, // Nonaktifkan jika mencapai batas
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            ),
          ),
        ),

        // Tampilan nilai
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
          onTapDown: (_) => setState(() {}), // Menyegarkan tampilan saat ditekan
          onTapUp: (_) => setState(() {}), // Kembali ke warna normal
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isMax ? Colors.grey : Colors.white, // Warna tombol
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: isMax ? Colors.black38 : Colors.black, size: 16),
              onPressed: isMax ? null : _increaseValue, // Nonaktifkan jika mencapai batas
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            ),
          ),
        ),
      ],
    );
  }
}
