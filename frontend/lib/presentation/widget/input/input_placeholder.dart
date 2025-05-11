import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InputPlaceholder extends StatefulWidget {
  final String label;
  final bool isPassword;
  final String? iconPath;
  final TextEditingController controller;
  final bool isEmail; // ➕ Tambahkan flag email

  const InputPlaceholder({
    super.key,
    required this.label,
    this.isPassword = false,
    this.iconPath,
    required this.controller,
    this.isEmail = false, // ➕ Default false
  });

  @override
  _InputPlaceholderState createState() => _InputPlaceholderState();
}

class _InputPlaceholderState extends State<InputPlaceholder> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: size.height * 0.06 < 50 ? 50 : size.height * 0.06,
          child: TextField(
            controller: widget.controller,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: size.width * 0.04,
              color: Colors.white,
            ),
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.isEmail ? TextInputType.emailAddress : TextInputType.text,
            textCapitalization: widget.isEmail ? TextCapitalization.none : TextCapitalization.sentences,
            onChanged: (value) {
              if (widget.isEmail) {
                final cursorPos = widget.controller.selection;
                widget.controller.text = value.toLowerCase();
                widget.controller.selection = cursorPos;
              }
            },
            decoration: InputDecoration(
              prefixIcon: widget.iconPath != null
                  ? Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Image.asset(widget.iconPath!,
                    width: size.width * 0.06, height: size.width * 0.06),
              )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: size.width * 0.05,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : null,
              labelText: widget.label,
              labelStyle: GoogleFonts.poppins(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                fontSize: size.width * 0.04,
                color: Colors.white,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02, horizontal: size.width * 0.03),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.025),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.025),
                borderSide: const BorderSide(color: Colors.white),
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
