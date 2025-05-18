import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoProfile extends StatelessWidget {
  final String label;
  final String info;

  const InfoProfile({
    super.key,
    required this.label,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white
          ),
        ),

        // Info
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6, left: 20),
          child: Text(
            info,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
                color: Colors.white
            ),
          ),
        ),

        Container(
          width: 250,
          height: 1.5,
          color: Colors.white.withAlpha(128),
        ),
      ],
    );
  }
}
