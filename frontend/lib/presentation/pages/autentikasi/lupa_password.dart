import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/autentikasi/login.dart';
import 'package:frontend_app/presentation/pages/autentikasi/reset_password.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';

import '../../../server/api_service.dart';
import '../../widget/background_widget.dart';
import '../../widget/input/input_placeholder.dart';
import '../../widget/input/input_otp.dart';
import '../../widget/button/button_filled.dart';
import '../../widget/button/button_text.dart';
import '../../widget/pop_up/custom_dialog.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  _LupaPasswordState createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _requestOTP() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email tidak boleh kosong!")),
      );
      return;
    }

    // **Validasi email harus mengandung '@'**
    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email harus mengandung '@'")),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    bool success = await ApiService.sendOTP(email);
    if (success) {
      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Kode OTP telah dikirim ke email Anda. Silakan cek email Anda.",
      );
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal mengirim OTP. Pastikan email sudah terdaftar.",
      );
    }
  }


  void _verifyOTP() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode OTP tidak boleh kosong!")),
      );
      return;
    }

    String? token = await ApiService.verifyOTP(emailController.text, otpController.text);
    if (token != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ResetPassword(token: token)),
      );
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Kode OTP yang Anda masukkan salah!",
      );
    }
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
                    "Lupa Password",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.09,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize),
                  Text(
                    "Silahkan masukkan email anda",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize * 1.5),
                  SizedBox(
                    width: size.width * 0.8,
                    child: InputPlaceholder(
                      label: "Email",
                      iconPath: "assets/icons/icon-email.png",
                      controller: emailController,
                    ),
                  ),
                  Gap(gapSize),
                  SizedBox(
                    child: ButtonFilled(
                      text: "Minta Kode OTP",
                      onPressed: _requestOTP,
                    ),
                  ),
                  const Gap(30),
                  Text(
                    "Silahkan masukkan kode OTP",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize * 1.5),
                  SizedBox(
                    width: size.width * 0.7,
                    child: InputOTP(controller: otpController),
                  ),
                  const Gap(20),
                  SizedBox(
                    child: ButtonFilled(
                      text: "Kirim Kode OTP",
                      onPressed: _verifyOTP,
                    ),
                  ),
                  const Gap(15),
                  ButtonText(
                    text: 'Kembali Login ?',
                    fontSize: size.width * 0.045,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
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
