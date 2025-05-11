import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/manajemen/user/tambah_user.dart';
import '../../widget/background_widget.dart';
import '../../widget/button/button_add.dart';
import '../../widget/navigation/navigasi_beranda.dart';
import '../../blocks/main_header.dart';
import '../../widget/tabel/tabel_manajemen_user.dart';
import 'beranda.dart';

class ManajemenUser extends StatefulWidget {
  const ManajemenUser({super.key});

  @override
  State<ManajemenUser> createState() => _ManajemenUserState();
}

class _ManajemenUserState extends State<ManajemenUser> {
  final GlobalKey<UserManagementTableState> _tableKey = GlobalKey();

  /// ✅ **Method untuk refresh tabel setelah user ditambah**
  void _refreshUserTable() {
    _tableKey.currentState?.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),
          const Positioned(left: 0, right: 0, top: 35, child: MainHeader()),

          Positioned.fill(
            top: screenHeight * 0.2,
            bottom: screenHeight * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar User",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      ButtonAdd(
                        text: "Tambah User",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TambahUser(
                                onUserAdded: _refreshUserTable, // ✅ Refresh tabel setelah tambah user
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 🔹 Tabel User dalam Expanded agar tidak tertutup
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: UserManagementTable(key: _tableKey), // ✅ Gunakan GlobalKey
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiBeranda(
              selectedIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Beranda()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
