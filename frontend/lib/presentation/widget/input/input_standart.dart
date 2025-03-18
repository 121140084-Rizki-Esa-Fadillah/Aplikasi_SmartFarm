import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InputStandart extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController? controller; // Tambahkan controller

  const InputStandart({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller, // Parameter controller
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Gap(8),
        SizedBox(
          height: size.height * 0.05 < 40 ? 40 : size.height * 0.05,
          child: TextField(
            controller: controller, // Gunakan controller di sini
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              color: Colors.white,
            ),
            obscureText: isPassword,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: size.height * 0.012,
                horizontal: size.width * 0.03,
              ),
              fillColor: Colors.transparent,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.025),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.025),
                borderSide: const BorderSide(color: Color(0xFF3A7CA5)),
              ),
            ),
            cursorColor: Colors.white,
          ),
        ),
        const Gap(20),
      ],
    );
  }
}
