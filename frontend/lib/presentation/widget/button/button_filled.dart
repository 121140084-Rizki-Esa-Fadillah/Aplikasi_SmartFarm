import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../color/color_constant.dart';

class ButtonFilled extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final bool enabled;

  const ButtonFilled({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstant.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
          minimumSize: const Size(0, 0),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF3A7CA5);
              }
              return null;
            },
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
