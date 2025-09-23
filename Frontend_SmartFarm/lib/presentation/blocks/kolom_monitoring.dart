import 'package:flutter/material.dart';
import '../../color/color_constant.dart';
import '../pages/monitoring/monitoirng_sensor/pengaturan_sensor.dart';
import '../widget/button/button_text.dart';
import '../widget/chart/chart_sensor.dart';

class KolomMonitoring extends StatefulWidget {
  final String pondId;
  final String namePond;
  final String sensorName;
  final String sensorType;
  final List<Map<String, dynamic>> sensorData;

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

  String formatSensorValue(String value, String sensorType) {
    double parsedValue = double.tryParse(value) ?? 0.0;
    String formattedValue = parsedValue.toStringAsFixed(2);

    switch (sensorType) {
      case 'temperature':
        return '$formattedValue °C';
      case 'salinity':
        return '$formattedValue PPT';
      case 'turbidity':
        return '$formattedValue NTU';
      default:
        return formattedValue; // pH
    }
  }

  String getButtonText(String sensorType) {
    switch (sensorType) {
      case 'temperature':
        return "Pengaturan Sensor Suhu >>";
      case 'salinity':
        return "Pengaturan Sensor Salinitas >>";
      case 'turbidity':
        return "Pengaturan Sensor Kekeruhan >>";
      default:
        return "Pengaturan Sensor pH >>";
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
      height: screenHeight * 0.35,
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
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screenWidth * 0.5,
              height: screenHeight * 0.05,
              decoration: const BoxDecoration(
                color: Color(0xFFD9DCD6),
                borderRadius: BorderRadius.only(
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
                  color: ColorConstant.primary,
                ),
              ),
            ),
          ),

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

          Positioned(
            top: screenHeight * 0.08,
            left: paddingValue,
            right: paddingValue,
            bottom: screenHeight * 0.07,
            child: ChartSensor(sensorData: widget.sensorData),
          ),

          Positioned(
            left: paddingValue,
            right: paddingValue,
            bottom: screenHeight * 0.05,
            child: Divider(
              color: Colors.white,
              thickness: 1,
            ),
          ),

          Positioned(
            left: paddingValue,
            right: paddingValue,
            bottom: 0,
            child: Center(
              child: ButtonText(
                text: getButtonText(widget.sensorType),
                icon: Icons.settings,
                onPressed: () {
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
