import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../color/color_constant.dart';

class ButtonText extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final Color defaultColor;
  final IconData? icon;

  const ButtonText({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 14,
    this.defaultColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return ColorConstant.primary;
            }
            return defaultColor;
          },
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize * 1.4, color: defaultColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
