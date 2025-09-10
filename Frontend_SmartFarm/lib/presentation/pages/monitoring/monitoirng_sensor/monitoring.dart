import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontend_app/presentation/pages/monitoring/kontrol_pakan_aerator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../server/api_service.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../beranda/beranda_admin.dart';
import '../../beranda/beranda_user.dart';
import '../riwayat_kualitas_air/riwayat_kualitas_air.dart';
import '../notifikasi.dart';
import '../../../widget/navigation/navigasi_monitoring.dart';
import '../../../widget/background_widget.dart';
import '../../../blocks/kolom_monitoring.dart';
import 'package:frontend_app/data/sensor_data_store.dart';

class Monitoring extends StatefulWidget {
  final String pondId;
  final String namePond;

  const Monitoring({super.key, required this.pondId, required this.namePond});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  bool isLoading = true;
  Timer? _sensorFetchTimer;

  final SensorDataStore _sensorStore = SensorDataStore();

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    _sensorFetchTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSensorData();
    });
  }

  @override
  void dispose() {
    _sensorFetchTimer?.cancel();
    super.dispose();
  }

  void fetchSensorData() async {
    try {
      final data = await ApiService.getMonitoringData(widget.pondId);
      if (mounted) {
        setState(() {
          _sensorStore.updateSensorHistory(widget.pondId, "temperature", data["temperature"]);
          _sensorStore.updateSensorHistory(widget.pondId, "ph", data["ph"]);
          _sensorStore.updateSensorHistory(widget.pondId, "salinity", data["salinity"]);
          _sensorStore.updateSensorHistory(widget.pondId, "turbidity", data["turbidity"]);

          _sensorStore.setSensorData(widget.pondId, data);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final sensorHistory = {
      "temperature": _sensorStore.getHistory(widget.pondId, "temperature"),
      "ph": _sensorStore.getHistory(widget.pondId, "ph"),
      "salinity": _sensorStore.getHistory(widget.pondId, "salinity"),
      "turbidity": _sensorStore.getHistory(widget.pondId, "turbidity"),
    };

    return Scaffold(
      appBar: AppBarWidget(
        title: "Monitoring",
        onBackPress: () async {
          final prefs = await SharedPreferences.getInstance();
          final role = prefs.getString('role');

          if (role == "Admin") {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BerandaAdmin()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BerandaUser()),
            );
          }
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          Positioned(
            top: screenHeight * 0.0,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            bottom: screenHeight * 0.10,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  KolomMonitoring(
                    pondId: widget.pondId,
                    sensorName: 'Sensor Suhu',
                    sensorType: 'temperature',
                    sensorData: sensorHistory["temperature"] ?? [],
                    namePond: widget.namePond,
                  ),
                  const SizedBox(height: 20),
                  KolomMonitoring(
                    pondId: widget.pondId,
                    sensorName: 'Sensor pH',
                    sensorType: 'ph',
                    sensorData: sensorHistory["ph"] ?? [],
                    namePond: widget.namePond,
                  ),
                  const SizedBox(height: 20),
                  KolomMonitoring(
                    pondId: widget.pondId,
                    sensorName: 'Sensor Salinitas',
                    sensorType: 'salinity',
                    sensorData: sensorHistory["salinity"] ?? [],
                    namePond: widget.namePond,
                  ),
                  const SizedBox(height: 20),
                  KolomMonitoring(
                    pondId: widget.pondId,
                    sensorName: 'Sensor Kekeruhan',
                    sensorType: 'turbidity',
                    sensorData: sensorHistory["turbidity"] ?? [],
                    namePond: widget.namePond,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Navigasi
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
                    MaterialPageRoute(
                      builder: (context) => RiwayatKualitasAir(
                        pondId: widget.pondId,
                        namePond: widget.namePond,
                      ),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Notifikasi(
                        pondId: widget.pondId,
                        namePond: widget.namePond,
                      ),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KontrolPakanAerator(
                        pondId: widget.pondId,
                        namePond: widget.namePond,
                      ),
                    ),
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
