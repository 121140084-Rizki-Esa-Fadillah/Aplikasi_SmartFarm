import 'package:flutter/material.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/navigation/navigasi_monitoring.dart';
import '../../../widget/tabel/tabel_laporan.dart';
import '../kontrol_pakan_aerator.dart';
import '../monitoirng_sensor/monitoring.dart';
import '../notifikasi.dart';

class LaporanKualitasAir extends StatelessWidget {
  final String date;
  final String pondId;
  final String namePond;
  final String historyId;

  const LaporanKualitasAir({
    super.key,
    required this.date,
    required this.pondId,
    required this.historyId,
    required this.namePond,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Laporan Kualitas Air",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          // **Konten Utama Riwayat Laporan**
          Positioned(
            top: screenHeight * 0.04,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            bottom: screenHeight * 0.10, // Menyesuaikan batas bawah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Title Tanggal (Tetap)**
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '$namePond $date',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // **Tabel Laporan**
                LaporanTable(id: historyId),
              ],
            ),
          ),

          // **Navigasi Monitoring di Bawah**
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiMonitoring(
              selectedIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Monitoring(pondId: pondId, namePond: namePond)),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Notifikasi(pondId: pondId, namePond: namePond)),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => KontrolPakanAerator(pondId: pondId, namePond: namePond)),
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
