import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InputRolePlaceholder extends StatefulWidget {
  final Function(String) onRoleSelected;

  const InputRolePlaceholder({super.key, required this.onRoleSelected});

  @override
  _InputRolePlaceholderState createState() => _InputRolePlaceholderState();
}

class _InputRolePlaceholderState extends State<InputRolePlaceholder> {
  String? selectedRole;
  bool isDropdownOpened = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: screenHeight * 0.06 < 50 ? 50 : screenHeight * 0.06,
          child: TextField(
            readOnly: true,
            controller: TextEditingController(text: selectedRole ?? ""),
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Image.asset(
                  "assets/icons/icon-role.png",
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.08,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    isDropdownOpened = !isDropdownOpened;
                  });
                },
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isDropdownOpened ? 0.5 : 0,
                  child: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 24),
                ),
              ),
              labelText: "Role",
              labelStyle: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.transparent,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            cursorColor: Colors.white,
            onTap: () {
              setState(() {
                isDropdownOpened = !isDropdownOpened;
              });
            },
          ),
        ),

        if (isDropdownOpened)
          Container(
            width: screenWidth * 0.9,
            margin: EdgeInsets.only(top: screenHeight * 0.008),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ["Admin", "User"].map((role) {
                bool isSelected = selectedRole == role;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD9DCD6) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      role,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedRole = role;
                        isDropdownOpened = false;
                      });
                      widget.onRoleSelected(role);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

        Gap(screenHeight * 0.02),
      ],
    );
  }
}
