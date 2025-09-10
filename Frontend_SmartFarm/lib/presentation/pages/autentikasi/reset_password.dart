import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../server/api_service.dart';
import '../../widget/background_widget.dart';
import '../../widget/button/button_filled.dart';
import '../../widget/input/input_placeholder.dart';
import '../../widget/pop_up/custom_dialog.dart';
import 'login.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPassword extends StatefulWidget {
  final String token;

  const ResetPassword({super.key, required this.token});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showDialog(false, "Password dan confirm password tidak boleh kosong");
      return;
    }

    if (password != confirmPassword) {
      _showDialog(false, "Password tidak cocok dengan confirm password");
      return;
    }

    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#\$&*~_-]).{8,20}$');

    if (!passwordRegex.hasMatch(password)) {
      _showDialog(false,
          "Password harus 8-16 karakter, mengandung angka dan simbol (seperti : !@#\$&*~-_).\nContoh: Tambak@123");
      return;
    }

    bool success = await ApiService.resetPassword(widget.token, password);

    if (success) {
      _showDialog(true, "Password berhasil diperbarui. Silakan login dengan password baru.", onComplete: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()),
        );
      });
    } else {
      _showDialog(false, "Gagal memperbarui password. Silakan coba lagi.");
    }
  }

  void _showDialog(bool isSuccess, String message, {VoidCallback? onComplete}) {
    CustomDialog.show(
      context: context,
      isSuccess: isSuccess,
      message: message,
      onComplete: onComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingHorizontal = size.width * 0.1;
    final double gapSize = size.height * 0.02;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Reset Password",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.09,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize),
                  Text(
                    "Silahkan masukkan password baru",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize * 2),
                  InputPlaceholder(
                    label: "Password",
                    iconPath: "assets/icons/icon-password.png",
                    isPassword: true,
                    controller: passwordController,
                  ),
                  Gap(gapSize * 0.5),
                  InputPlaceholder(
                    label: "Confirm Password",
                    iconPath: "assets/icons/icon-password.png",
                    isPassword: true,
                    controller: confirmPasswordController,
                  ),
                  Gap(gapSize * 2),
                  SizedBox(
                    width: size.width * 0.5,
                    child: ButtonFilled(
                      text: 'Simpan',
                      onPressed: _resetPassword,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
