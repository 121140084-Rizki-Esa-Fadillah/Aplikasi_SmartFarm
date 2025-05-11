import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/blocks/tile_kolam.dart';
import 'package:frontend_app/server/api_service.dart';
import '../../blocks/main_header.dart';
import '../../widget/background_widget.dart';

class BerandaUser extends StatefulWidget {
  const BerandaUser({super.key});

  @override
  State<BerandaUser> createState() => _BerandaUserState();
}

class _BerandaUserState extends State<BerandaUser> {
  List<Map<String, dynamic>> pondList = [];

  @override
  void initState() {
    super.initState();
    fetchPonds();
  }

  Future<void> fetchPonds() async {
    final data = await ApiService.getKolam();
    setState(() {
      pondList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),

          // **Header**
          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.05,
            child: const MainHeader(),
          ),

          // **Konten Utama**
          Positioned(
            top: screenHeight * 0.20,
            left: screenWidth * 0.06,
            right: screenWidth * 0.05,
            bottom: screenHeight * 0.10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Judul "Daftar Kolam"**
                Text(
                  "Daftar Kolam",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),

                // **GridView untuk TileKolam**
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = screenWidth < 600 ? 2 : 3;
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: screenWidth * 0.02,
                          mainAxisSpacing: screenHeight * 0.02,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: pondList.length,
                        itemBuilder: (context, index) {
                          var pond = pondList[index];
                          return TileKolam(
                            pondId: pond["idPond"],
                            pondName: pond["namePond"],
                            status: pond["statusPond"],
                            date: pond["createdAt"].toString().substring(0, 10),
                            pondData: pond,
                            onEdit: (_) {}, // Tidak digunakan
                            onDelete: () {}, // Tidak digunakan
                            showMenu: false, // Tidak menampilkan menu edit/hapus
                          );
                        },
                      );
                    },
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
