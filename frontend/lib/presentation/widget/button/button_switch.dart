import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';

class ButtonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ButtonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 25,
          child: Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: ColorConstant.primary,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ),
        Text(
          "Status: ${value ? "On" : "Off"}",
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: ColorConstant.primary,
          ),
        ),
      ],
    );
  }
}