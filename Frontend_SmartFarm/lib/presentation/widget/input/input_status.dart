import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InputStatus extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const InputStatus({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _InputStatusState createState() => _InputStatusState();
}

class _InputStatusState extends State<InputStatus> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialValue;
  }

  bool isDropdownOpened = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          "Status Kolam",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Gap(8),

        // Input field
        SizedBox(
          height: size.height * 0.05 < 40 ? 40 : size.height * 0.05,
          child: TextField(
            readOnly: true,
            controller: TextEditingController(text: selectedRole),
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              color: Colors.white,
            ),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

        // Dropdown List
        if (isDropdownOpened)
          Container(
            width: size.width * 0.9,
            margin: EdgeInsets.only(top: size.height * 0.008),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ["Aktif", "Non-Aktif"].map((role) {
                bool isSelected = selectedRole == role;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD9DCD6) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                      widget.onChanged(role);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
