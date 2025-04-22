import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputScheduleTime extends StatefulWidget {
  final String label;
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected; // Callback untuk mengupdate waktu

  const InputScheduleTime({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  _InputScheduleTimeState createState() => _InputScheduleTimeState();
}

class _InputScheduleTimeState extends State<InputScheduleTime> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime; // Gunakan waktu awal dari parameter
  }

  // Fungsi untuk menampilkan Time Picker
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onTimeSelected(picked); // Kirim data waktu yang dipilih ke parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            "${widget.label} :",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // Waktu yang dapat diklik
          GestureDetector(
            onTap: () => _pickTime(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF003A5D),
                  ),
                ),

                // Ikon jam
                IconButton(
                  icon: const Icon(Icons.access_time, color: Colors.white, size: 18),
                  onPressed: () => _pickTime(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
