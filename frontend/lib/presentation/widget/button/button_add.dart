import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../color/color_constant.dart';

class ButtonAdd extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;

  const ButtonAdd({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = false,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 1,
          minimumSize: const Size(0, 0),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF3A7CA5);
            }
            return null;
          }),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.add, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
