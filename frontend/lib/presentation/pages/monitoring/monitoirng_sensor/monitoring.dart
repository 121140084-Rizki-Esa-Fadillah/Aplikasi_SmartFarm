import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/monitoring/kontrol_pakan_aerator.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../riwayat_kualitas_air/riwayat_kualitas_air.dart';
import '../notifikasi.dart';
import '../../../widget/navigation/navigasi_monitoring.dart';
import '../../../widget/background_widget.dart';
import '../../../blocks/kolom_monitoring.dart'; // Import KolomMonitoring

class Monitoring extends StatelessWidget {
  final String pondId;
  final String namePond; // ✅ Tambahkan namePond

  const Monitoring({super.key, required this.pondId, required this.namePond});

  @override
  Widget build(BuildContext context) {
    debugPrint("Halaman Monitoring dibuka untuk pondId: $pondId");
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // ** Data Dummy untuk Grafik Sensor **
    final List<Map<String, dynamic>> dummyTemperatureData = [
      {"time": "00:00", "value": 28.5},
      {"time": "03:00", "value": 29.0},
      {"time": "06:00", "value": 28.8},
      {"time": "09:00", "value": 29.2},
      {"time": "12:00", "value": 30.0},
      {"time": "15:00", "value": 29.5},
      {"time": "18:00", "value": 28.9},
      {"time": "21:00", "value": 28.7},
    ];

    final List<Map<String, dynamic>> dummyPHData = [
      {"time": "00:00", "value": 7.1},
      {"time": "03:00", "value": 7.3},
      {"time": "06:00", "value": 7.4},
      {"time": "09:00", "value": 7.2},
      {"time": "12:00", "value": 7.5},
      {"time": "15:00", "value": 7.4},
      {"time": "18:00", "value": 7.2},
      {"time": "21:00", "value": 7.3},
    ];

    final List<Map<String, dynamic>> dummySalinityData = [
      {"time": "00:00", "value": 30},
      {"time": "03:00", "value": 29.8},
      {"time": "06:00", "value": 30.2},
      {"time": "09:00", "value": 30.5},
      {"time": "12:00", "value": 30.1},
      {"time": "15:00", "value": 29.9},
      {"time": "18:00", "value": 30.3},
      {"time": "21:00", "value": 30.0},
    ];

    final List<Map<String, dynamic>> dummyTurbidityData = [
      {"time": "00:00", "value": 18},
      {"time": "03:00", "value": 17.5},
      {"time": "06:00", "value": 18.2},
      {"time": "09:00", "value": 18.5},
      {"time": "12:00", "value": 19.0},
      {"time": "15:00", "value": 18.3},
      {"time": "18:00", "value": 17.8},
      {"time": "21:00", "value": 18.1},
    ];

    return Scaffold(
      appBar: AppBarWidget(
        title: "Monitoring",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          // **Konten Utama**
          Positioned(
            top: screenHeight * 0.0,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            bottom: screenHeight * 0.10, // Tambahkan batas agar tidak menabrak navigasi
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  KolomMonitoring(
                    pondId: pondId,
                    sensorName: 'Sensor Suhu',
                    sensorType: 'temperature', // 🔹 Tambahkan sensorType
                    sensorData: dummyTemperatureData,
                    namePond: namePond,
                  ),
                  const SizedBox(height: 10),
                  KolomMonitoring(
                    pondId: pondId,
                    sensorName: 'Sensor pH',
                    sensorType: 'ph', // 🔹 Tambahkan sensorType
                    sensorData: dummyPHData,
                    namePond: namePond,
                  ),
                  const SizedBox(height: 10),
                  KolomMonitoring(
                    pondId: pondId,
                    sensorName: 'Sensor Salinitas',
                    sensorType: 'salinity', // 🔹 Tambahkan sensorType
                    sensorData: dummySalinityData,
                    namePond: namePond,
                  ),
                  const SizedBox(height: 10),
                  KolomMonitoring(
                    pondId: pondId,
                    sensorName: 'Sensor Kekeruhan',
                    sensorType: 'turbidity', // 🔹 Tambahkan sensorType
                    sensorData: dummyTurbidityData,
                    namePond: namePond,
                  ),

                  const SizedBox(height: 20), // Jarak di bawah agar tidak tertutup navigasi
                ],
              ),
            ),
          ),

          // **Navigasi Monitoring dalam Stack**
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiMonitoring(
              selectedIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatKualitasAir(pondId: pondId, namePond: namePond)),
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
