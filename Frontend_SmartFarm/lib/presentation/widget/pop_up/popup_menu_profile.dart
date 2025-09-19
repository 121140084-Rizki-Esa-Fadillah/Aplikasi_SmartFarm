import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/manajemen/profile/profile.dart';
import 'package:frontend_app/presentation/pages/manajemen/profile/edit_profile.dart';
import 'package:frontend_app/presentation/pages/autentikasi/login.dart';
import 'package:frontend_app/server/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../blocks/notifikasi_item.dart';
import 'custom_dialog_button.dart';

class PopupMenuProfile extends StatefulWidget {
  final double leftPosition;
  final double topPosition;
  final double buttonWidth;

  const PopupMenuProfile({
    super.key,
    required this.leftPosition,
    required this.topPosition,
    required this.buttonWidth,
  });

  @override
  State<PopupMenuProfile> createState() => _PopupMenuProfileState();
}

class _PopupMenuProfileState extends State<PopupMenuProfile> {
  bool _notificationsEnabled = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationStatus();
    });
  }

  Future<String?> _getCurrentUserId() async {
    final profile = await ApiService.getProfile();
    if (profile != null && profile.containsKey('_id')) {
      return profile['_id'];
    }
    return null;
  }

  void _infoProfile() {
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  void _editProfile() {
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const EditProfile()),
    );
  }


  Future<void> _checkNotificationStatus() async {
    final profile = await ApiService.getProfile();
    if (profile == null || !profile.containsKey('_id')) return;

    final userId = profile['_id'];
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('notifications_enabled_$userId') ?? true;

    if (mounted) {
      setState(() {
        _notificationsEnabled = status;
        _loading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled_$userId', value);

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic('global_notifications');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('global_notifications');
    }
  }


  void _logout() async {
    CustomDialogButton.show(
      context: MyApp.navigatorKey.currentContext!,
      title: "Konfirmasi Logout",
      message: "Apakah Anda yakin ingin logout?",
      confirmText: "Ya",
      onConfirm: () async {
        final prefs = await SharedPreferences.getInstance();
        //final userId = await _getCurrentUserId();
        //if (userId != null) {
        //  await prefs.remove('notifications_enabled_$userId');
        //}
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

  Future<bool> _fetchNotificationStatus() async {
    final profile = await ApiService.getProfile();
    if (profile == null || !profile.containsKey('_id')) return true;

    final userId = profile['_id'];
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled_$userId') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<bool>(
      future: _fetchNotificationStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentNotificationStatus = snapshot.data!;

        return Stack(
          children: [
            Positioned(
              left: widget.leftPosition,
              top: widget.topPosition,
              width: size.width * 0.475,
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
                          _infoProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.edit,
                        text: "Edit Profile",
                        color: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          _editProfile();
                        },
                      ),
                      _buildDivider(),

                      NotifikasiItem(
                        initialValue: currentNotificationStatus,
                        onToggle: _toggleNotifications,
                      ),

                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.logout,
                        text: "Logout",
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _logout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
              Text(text, style: const TextStyle(fontSize: 14)),
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

