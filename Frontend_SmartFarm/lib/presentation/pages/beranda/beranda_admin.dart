import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/blocks/tile_kolam.dart';
import 'package:frontend_app/presentation/pages/manajemen/kolam/tambah_kolam.dart';
import 'package:frontend_app/server/api_service.dart';
import '../../blocks/main_header.dart';
import '../../widget/button/button_add.dart';
import '../../widget/navigation/navigasi_beranda.dart';
import '../../widget/background_widget.dart';
import '../../widget/pop_up/custom_dialog_button.dart';
import '../manajemen/kolam/edit_kolam.dart';
import 'manajemen_user.dart';

class BerandaAdmin extends StatefulWidget {
  const BerandaAdmin({super.key});

  @override
  State<BerandaAdmin> createState() => _BerandaAdminState();
}

class _BerandaAdminState extends State<BerandaAdmin> {
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

  void _EditPond(BuildContext context, Map<String, dynamic> pond) async {
    final updatedPond = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditKolam(
          id: pond["_id"],
          pondId: pond["idPond"],
          pondName: pond["namePond"],
          status: pond["statusPond"],
        ),
      ),
    );

    if (updatedPond != null) {
      fetchPonds();
    }
  }


  void _DeletePond(String id, String pondName) {
    CustomDialogButton.show(
      context: context,
      title: "Konfirmasi Hapus",
      message: "Apakah Anda yakin ingin menghapus kolam \"$pondName\"? Tindakan ini tidak dapat dibatalkan.",
      confirmText: "Hapus",
      cancelText: "Batal",
      isWarning: true,
      onConfirm: () async {
        bool deleted = await ApiService.deleteKolam(id);
        if (deleted) {
          setState(() {
            pondList.removeWhere((pond) => pond["_id"] == id);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.05,
            child: const MainHeader(),
          ),
          Positioned(
            top: screenHeight * 0.20,
            left: screenWidth * 0.06,
            right: screenWidth * 0.05,
            bottom: screenHeight * 0.10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Daftar Kolam",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ButtonAdd(
                      text: "Tambah Kolam",
                      onPressed: () async {
                        bool? result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TambahKolam(
                              onKolamAdded: fetchPonds,
                            ),
                          ),
                        );

                        if (result == true) {
                          fetchPonds();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
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
                            onEdit: (selectedPond) => _EditPond(context, selectedPond),
                            onDelete: () => _DeletePond(pond["_id"], pond["namePond"]),
                            showMenu: true,
                          );
                        },
                      );
                    },
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
              selectedIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ManajemenUser()),
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
