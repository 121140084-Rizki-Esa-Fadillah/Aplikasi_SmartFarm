import 'package:flutter/material.dart';
import '../../../../server/api_service.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/button/button_filled.dart';
import '../../../widget/input/input_standart.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/input/input_role_standart.dart';
import '../../../widget/pop_up/custom_dialog.dart';

class EditUser extends StatefulWidget {
  final String userId;
  final String username;
  final String email;
  final String role;
  final Function onUpdateSuccess;

  const EditUser({
    super.key,
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.onUpdateSuccess,
  });

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _selectedRole = widget.role;
  }

  Future<void> _EditUser() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String role = _selectedRole ?? widget.role;

    if (username.isEmpty || email.isEmpty) {
      _showDialog(false, "Username dan email tidak boleh kosong");
      return;
    }

    if (username.length < 4 || username.length > 16) {
      _showDialog(false, "Username harus antara 4 hingga 16 karakter");
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

    final checkResult = await ApiService.checkUsernameEmail(username, email);
    if (checkResult == null) {
      _showDialog(false, "Gagal memeriksa ketersediaan username/email.");
      return;
    }

    bool usernameConflict = (checkResult["usernameExists"] == true && username != widget.username);
    bool emailConflict = (checkResult["emailExists"] == true && email != widget.email);

    if (usernameConflict || emailConflict) {
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

    setState(() => _isLoading = true);
    bool success = await ApiService.editUser(widget.userId, username, email, role);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showDialog(
        true,
        "Data pengguna berhasil diperbarui!",
        onComplete: () {
          widget.onUpdateSuccess();
          Navigator.pop(context);
        },
      );
    } else {
      _showDialog(false, "Gagal memperbarui data pengguna. Coba lagi.");
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
    return Scaffold(
      appBar: AppBarWidget(
        title: "Edit User",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputStandart(
                          label: "Username",
                          controller: _usernameController,
                        ),
                        const SizedBox(height: 12),
                        InputStandart(
                          label: "Email",
                          controller: _emailController,
                          isEmail: true,
                        ),
                        const SizedBox(height: 12),
                        InputRoleStandart(
                          selectedRole: _selectedRole,
                          onRoleChanged: (role) {
                            setState(() {
                              _selectedRole = role;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ButtonFilled(
                      text: "Simpan",
                      onPressed: _isLoading ? () {} : _EditUser,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
