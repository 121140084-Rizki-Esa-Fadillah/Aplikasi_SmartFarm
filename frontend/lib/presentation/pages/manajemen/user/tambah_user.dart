import 'package:flutter/material.dart';
import '../../../../server/api_service.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/button/button_filled.dart';
import '../../../widget/input/input_placeholder.dart';
import '../../../widget/input/input_role_placeholder.dart';
import '../../../widget/pop_up/custom_dialog.dart';

class TambahUser extends StatefulWidget {
  final VoidCallback onUserAdded; // ✅ Callback untuk update tabel otomatis

  const TambahUser({super.key, required this.onUserAdded});

  @override
  State<TambahUser> createState() => _TambahUserState();
}

class _TambahUserState extends State<TambahUser> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? selectedRole;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _AddUser() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedRole == null) {
      _showDialog(false, "Semua field harus diisi");
      return;
    }
    if (username.length < 4 || username.length > 16) {
      _showDialog(false, "Username harus 4-16 karakter");
      return;
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(email)) {
      _showDialog(false, "Format email tidak valid. Harap gunakan format yang benar.");
      return;
    }

    final isDomainValid = await ApiService.checkEmailDomain(email);
    if (!isDomainValid) {
      _showDialog(false, "Domain email tidak aktif atau tidak valid.");
      return;
    }

    if (password != confirmPassword) {
      _showDialog(false, "Password tidak cocok dengan confirm password");
      return;
    }

    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#\$&*~_-]).{8,16}$');
    if (!passwordRegex.hasMatch(password)) {
      _showDialog(false,
          "Password harus 8-16 karakter, mengandung angka dan simbol (seperti : !@#\$&*~-_).\nContoh: Tambak@123");
      return;
    }

    setState(() => isLoading = true);

    final checkResult = await ApiService.checkUsernameEmail(username, email);

    if (checkResult == null) {
      setState(() => isLoading = false);
      _showDialog(false, "Gagal mengecek data pengguna");
      return;
    }

    bool usernameConflict = checkResult["usernameExists"] == true;
    bool emailConflict = checkResult["emailExists"] == true;
    if (usernameConflict || emailConflict) {
      setState(() => isLoading = false);
      String message = "";
      if (usernameConflict && emailConflict) {
        message = "Username dan Email sudah digunakan, harap gunakan username dan email yang lain.";
      } else if (usernameConflict) {
        message = "Username sudah digunakan, harap gunakan username yang lain.";
      } else if (emailConflict) {
        message = "Email sudah digunakan, harap gunakan email yang lain.";
      }
      _showDialog(false, message);
      return;
    }

    bool success = await ApiService.addUser(username, email, password, selectedRole!);

    setState(() => isLoading = false);

    _showDialog(
      success,
      success ? "User berhasil ditambahkan" : "Gagal menambahkan user",
      onComplete: () {
        if (success) {
          widget.onUserAdded();
          Navigator.pop(context);
        }
      },
    );
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

    return Scaffold(
      appBar: AppBarWidget(
        title: "Tambah User",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundWidget(),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: size.width * 0.08,
                    right: size.width * 0.08,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          InputPlaceholder(
                            label: "Username",
                            iconPath: "assets/icons/icon-username.png",
                            controller: usernameController,
                          ),
                          InputPlaceholder(
                            label: "Email",
                            iconPath: "assets/icons/icon-email.png",
                            controller: emailController,
                            isEmail: true,
                          ),
                          InputRolePlaceholder(
                            onRoleSelected: (role) {
                              setState(() {
                                selectedRole = role;
                              });
                            },
                          ),
                          InputPlaceholder(
                            label: "Password",
                            isPassword: true,
                            iconPath: "assets/icons/icon-password.png",
                            controller: passwordController,
                          ),
                          InputPlaceholder(
                            label: "Confirm Password",
                            isPassword: true,
                            iconPath: "assets/icons/icon-password.png",
                            controller: confirmPasswordController,
                          ),
                          const SizedBox(height: 20),
                          const Spacer(), //
                          SizedBox(
                            width: double.infinity,
                            child: ButtonFilled(
                              text: "Simpan",
                              onPressed: isLoading ? () {} : _AddUser,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
