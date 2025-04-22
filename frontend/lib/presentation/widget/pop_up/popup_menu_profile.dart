import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/manajemen/profile/profile.dart';
import 'package:frontend_app/presentation/pages/manajemen/profile/edit_profile.dart';
import 'package:frontend_app/presentation/pages/autentikasi/login.dart';
import 'package:frontend_app/server/api_service.dart';
import '../../../main.dart';
import 'custom_dialog_button.dart';

class PopupMenuProfile extends StatelessWidget {
  final double leftPosition;
  final double topPosition;
  final double buttonWidth;

  const PopupMenuProfile({
    super.key,
    required this.leftPosition,
    required this.topPosition,
    required this.buttonWidth,
  });

  void _logout() async {
    CustomDialogButton.show(
      context: MyApp.navigatorKey.currentContext!,
      title: "Konfirmasi Logout",
      message: "Apakah Anda yakin ingin logout?",
      confirmText: "Ya",
      onConfirm: () async {

        await ApiService.logout();

        MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
        );
      },
      cancelText: "Batal",
      isWarning: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: leftPosition,
          top: topPosition,
          width: buttonWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(
                    icon: Icons.info,
                    text: "Info Profile",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      MyApp.navigatorKey.currentState?.push(
                        MaterialPageRoute(builder: (context) => const Profile()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.edit,
                    text: "Edit Profile",
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      MyApp.navigatorKey.currentState?.push(
                        MaterialPageRoute(builder: (context) => const EditProfile()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    text: "Logout",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _logout(); // Tampilkan dialog konfirmasi logout
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        splashColor: color.withAlpha(70),
        highlightColor: color.withAlpha(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Colors.grey);
  }
}
