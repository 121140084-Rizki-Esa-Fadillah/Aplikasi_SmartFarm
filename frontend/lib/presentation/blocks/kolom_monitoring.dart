import 'package:flutter/material.dart';
import '../../color/color_constant.dart';
import '../../server/api_service.dart';
import '../pages/monitoring/monitoirng_sensor/pengaturan_sensor.dart';
import '../widget/chart/chart_sensor.dart';

class KolomMonitoring extends StatefulWidget {
  final String pondId;
  final String namePond;
  final String sensorName;
  final String sensorType;
  final List<Map<String, dynamic>> sensorData; // Realtime data (1 data point)

  const KolomMonitoring({
    super.key,
    required this.pondId,
    required this.sensorName,
    required this.sensorType,
    required this.sensorData,
    required this.namePond,
  });

  @override
  _KolomMonitoringState createState() => _KolomMonitoringState();
}

class _KolomMonitoringState extends State<KolomMonitoring> {
  bool isPressed = false;
  String sensorValue = "--";

  @override
  void initState() {
    super.initState();
    if (widget.sensorData.isNotEmpty) {
      sensorValue = widget.sensorData.last['value'].toString();
    }
  }

  // ✅ Update nilai sensor jika sensorData baru diterima
  @override
  void didUpdateWidget(covariant KolomMonitoring oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sensorData.isNotEmpty &&
        widget.sensorData.last['value'].toString() != sensorValue) {
      setState(() {
        sensorValue = widget.sensorData.last['value'].toString();
      });
    }
  }

  /// 🔹 Format nilai sensor
  String formatSensorValue(String value, String sensorType) {
    double parsedValue = double.tryParse(value) ?? 0.0;
    String formattedValue = parsedValue.toStringAsFixed(1);

    switch (sensorType) {
      case 'temperature':
        return '$formattedValue °C';
      case 'salinity':
        return '$formattedValue ppt';
      case 'turbidity':
        return '$formattedValue NTU';
      default:
        return formattedValue; // pH
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.05;
    double paddingValue = screenWidth * 0.03;

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.3,
      decoration: BoxDecoration(
        color: const Color(0x80D9DCD6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 🔹 Nama Sensor
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) {
                setState(() => isPressed = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PengaturanSensor(
                      pondId: widget.pondId,
                      sensorName: widget.sensorName,
                      currentValue: sensorValue,
                      namePond: widget.namePond,
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: screenWidth * 0.5,
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  color: isPressed
                      ? ColorConstant.primary
                      : const Color(0xFFD9DCD6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: paddingValue),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.sensorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color:
                    isPressed ? Colors.white : ColorConstant.primary,
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Nilai Sensor (auto update now!)
          Positioned(
            right: paddingValue,
            top: screenHeight * 0.01,
            child: Text(
              formatSensorValue(sensorValue, widget.sensorType),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize * 1.2,
                color: ColorConstant.primary,
              ),
            ),
          ),

          // 🔹 Grafik
          Positioned(
            top: screenHeight * 0.08,
            left: paddingValue,
            right: paddingValue,
            bottom: screenHeight * 0.02,
            child: ChartSensor(sensorData: widget.sensorData),
          ),
        ],
      ),
    );
  }
}
