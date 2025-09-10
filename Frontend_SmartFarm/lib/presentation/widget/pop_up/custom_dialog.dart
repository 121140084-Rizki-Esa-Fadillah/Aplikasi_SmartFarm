import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDialog {
  static void show({
    required BuildContext context,
    required bool isSuccess,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(duration, () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            if (onComplete != null) {
              onComplete();
            }
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 48,
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
