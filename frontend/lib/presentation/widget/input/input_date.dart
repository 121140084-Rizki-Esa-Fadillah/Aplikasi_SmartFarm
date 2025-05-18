import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../color/color_constant.dart';

class InputDate extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final Function()? onReset;
  final bool showCalendarIcon;

  const InputDate({
    super.key,
    this.onDateSelected,
    this.onReset,
    this.showCalendarIcon = true,
  });

  @override
  State<InputDate> createState() => _InputDateState();
}

class _InputDateState extends State<InputDate> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _dateController.text = "dd/mm/yyyy";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: TextField(
        controller: _dateController,
        readOnly: true,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ColorConstant.primary,
        ),
        decoration: InputDecoration(
          hintText: "dd/mm/yyyy",
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorConstant.primary),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

          suffixIcon: selectedDate != null
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: resetInput, // ✅ Tombol reset
          )
              : (widget.showCalendarIcon
              ? IconButton(
            icon: Icon(Icons.calendar_today, color: ColorConstant.primary),
            onPressed: () => _selectDate(context),
          )
              : null),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text =
        "${pickedDate.day.toString().padLeft(2, '0')}/"
            "${pickedDate.month.toString().padLeft(2, '0')}/"
            "${pickedDate.year}";
      });

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(pickedDate);
      }
    }
  }

  void resetInput() {
    setState(() {
      selectedDate = null;
      _dateController.text = "dd/mm/yyyy";
    });

    if (widget.onReset != null) {
      widget.onReset!(); // ✅ Panggil onReset jika ada
    }
  }
}
