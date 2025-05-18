import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonDetail extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final Color borderColor;
  final Color textColor;

  const ButtonDetail({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = false,
    this.borderColor = const Color(0xFF16425B),
    this.textColor = const Color(0xFF16425B),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size.zero),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: borderColor, width: 1),
          ),
          foregroundColor: WidgetStateProperty.all(textColor),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF81C3D7);
              }
              return Colors.transparent;
            },
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
