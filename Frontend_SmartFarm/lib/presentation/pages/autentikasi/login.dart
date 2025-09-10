import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/beranda/beranda_admin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../server/api_service.dart';
import '../../widget/background_widget.dart';
import '../../widget/button/button_filled.dart';
import '../../widget/input/input_placeholder.dart';
import '../../widget/button/button_text.dart';
import '../../widget/pop_up/custom_dialog.dart';
import '../beranda/beranda_user.dart';
import 'lupa_password.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showDialog(false, "Username dan password tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiService.login(username, password);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString("role");

      _showDialog(true, "Login berhasil!", onComplete: () {
        if (role == "Admin") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BerandaAdmin()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BerandaUser()),
          );
        }
      });
    } else {
      _showDialog(false, "Login gagal. Periksa kembali username/password.");
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.09,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize),
                  Text(
                    'Silahkan login dengan username dan password anda',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Gap(gapSize * 1.5),
                  InputPlaceholder(
                    label: 'Username',
                    iconPath: 'assets/icons/icon-username.png',
                    controller: usernameController,
                  ),
                  InputPlaceholder(
                    label: 'Password',
                    isPassword: true,
                    iconPath: 'assets/icons/icon-password.png',
                    controller: passwordController,
                  ),
                  Gap(gapSize),
                  SizedBox(
                    width: size.width * 0.5,
                    child: ButtonFilled(
                      text: 'Login',
                      onPressed: isLoading ? () {} : _login,
                    ),
                  ),
                  Gap(gapSize * 0.8),
                  ButtonText(
                    text: 'Lupa Password ?',
                    fontSize: size.width * 0.045,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LupaPassword()),
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