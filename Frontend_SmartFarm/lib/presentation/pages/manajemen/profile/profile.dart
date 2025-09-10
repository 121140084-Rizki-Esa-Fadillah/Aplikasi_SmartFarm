import 'package:flutter/material.dart';
import '../../../../server/api_service.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../blocks/info_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final data = await ApiService.getProfile();
    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Profile",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: userData == null
                ? const Center(child: CircularProgressIndicator()) // Loading Indicator
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Info Pengguna",
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                InfoProfile(label: "Username", info: userData?["username"] ?? "N/A"),
                const SizedBox(height: 16),
                InfoProfile(label: "Email", info: userData?["email"] ?? "N/A"),
                const SizedBox(height: 16),
                InfoProfile(label: "Role", info: userData?["role"] ?? "N/A"),
                const SizedBox(height: 16),
                InfoProfile(label: "Tanggal Daftar", info: userData?["createdAt"]?.substring(0, 10) ?? "N/A"),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
