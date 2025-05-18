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

  Future<void> _EditProfile() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim().toLowerCase();

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

    bool usernameConflict = checkResult["usernameExists"] == true && username != _currentUsername;
    bool emailConflict = checkResult["emailExists"] == true && email != _currentEmail;

    if (usernameConflict || emailConflict) {
      String message = usernameConflict && emailConflict
          ? "Username dan Email sudah digunakan, harap gunakan yang lain."
          : usernameConflict
          ? "Username sudah digunakan, harap gunakan username yang lain."
          : "Email sudah digunakan, harap gunakan email yang lain.";

      _showDialog(false, message);
      return;
    }

    setState(() => _isLoading = true);
    bool success = await ApiService.editProfile(username, email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showDialog(true, "Profil berhasil diperbarui!", onComplete: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Profile()),
        );
      });
    } else {
      _showDialog(false, "Gagal memperbarui profil. Coba lagi.");
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
                      onPressed: _isLoading ? () {} : _EditProfile,
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
