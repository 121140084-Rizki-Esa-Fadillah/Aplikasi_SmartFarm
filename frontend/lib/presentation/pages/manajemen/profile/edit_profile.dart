import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/manajemen/profile/profile.dart';
import '../../../../server/api_service.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/button/button_filled.dart';
import '../../../widget/input/input_standart.dart';
import '../../../widget/pop_up/custom_dialog.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _currentUsername;
  String? _currentEmail;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final userData = await ApiService.getProfile();
    if (userData != null) {
      setState(() {
        _currentUsername = userData["username"];
        _currentEmail = userData["email"];
        _usernameController.text = _currentUsername ?? "";
        _emailController.text = _currentEmail ?? "";
      });
    }
  }

  Future<void> _editProfile() async {
    debugPrint("Username: '${_usernameController.text}'");
    debugPrint("Email: '${_emailController.text}'");

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim().toLowerCase();;

    if (username.isEmpty || email.isEmpty) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Username dan email tidak boleh kosong",
      );
      return;
    }

    if (username.length < 4 || username.length > 16) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Username harus antara 4 hingga 16 karakter",
      );
      return;
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (!emailRegex.hasMatch(email)) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Format email tidak valid. Pastikan email mengandung '@' dan domain yang benar",
      );
      return;
    }

    // 🔍 Cek apakah username/email sudah dipakai orang lain
    final checkResult = await ApiService.checkUsernameEmail(username, email);

    if (checkResult == null) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal memeriksa ketersediaan username/email.",
      );
      return;
    }

    // ⚡ Cek hanya kalau username/email baru BEDA dari user lama
    if ((checkResult["usernameExists"] == true && username != _currentUsername) ||
        (checkResult["emailExists"] == true && email != _currentEmail)) {
      String message = "";

      bool usernameConflict = (checkResult["usernameExists"] == true && username != _currentUsername);
      bool emailConflict = (checkResult["emailExists"] == true && email != _currentEmail);

      if (usernameConflict && emailConflict) {
        message = "Username dan Email sudah digunakan, harap gunakan username dan email yang lain.";
      } else if (usernameConflict) {
        message = "Username sudah digunakan, harap gunakan username yang lain.";
      } else if (emailConflict) {
        message = "Email sudah digunakan, harap gunakan email yang lain.";
      }

      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: message,
      );
      return;
    }

    // ✅ Lanjut update
    setState(() => _isLoading = true);

    bool success = await ApiService.editProfile(username, email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Profil berhasil diperbarui!",
        onComplete: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        },
      );
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal memperbarui profil. Coba lagi.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Edit Profile",
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        InputStandart(label: "Username", controller: _usernameController),
                        const SizedBox(height: 12),
                        InputStandart(label: "Email", controller: _emailController, isEmail: true,),
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
                      onPressed: _isLoading ? () {} : _editProfile,
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
