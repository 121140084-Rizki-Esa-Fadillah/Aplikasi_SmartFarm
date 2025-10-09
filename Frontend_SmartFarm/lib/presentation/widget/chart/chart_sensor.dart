
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartSensor extends StatelessWidget {
  final List<Map<String, dynamic>> sensorData;

  const ChartSensor({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScale = MediaQuery.of(context).textScaleFactor;

    if (sensorData.isEmpty) {
      return Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 16 * textScale),
        ),
      );
    }

    // Ambil nilai tertinggi & terendah dari sensor untuk set minY dan maxY
    final values = sensorData.map((e) => (e["value"] as num).toDouble()).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxValue - minValue) * 0.1; // beri jarak 10%

    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.02),
      child: LineChart(
        LineChartData(
          minY: minValue - yPadding,
          maxY: maxValue + yPadding,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenWidth * 0.08,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.005),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(fontSize: 10 * textScale),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenHeight * 0.03,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < sensorData.length) {
                    return Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.005),
                      child: Text(
                        sensorData[index]["time"],
                        style: TextStyle(fontSize: 10 * textScale),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey),
              bottom: BorderSide(color: Colors.grey),
              right: BorderSide(color: Colors.transparent),
              top: BorderSide(color: Colors.transparent),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: sensorData.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value["value"] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.15,
              color: Colors.blue,
              barWidth: screenWidth * 0.007,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withAlpha(50),
              ),
              dotData: FlDotData(show: true), // Tampilkan titik
            ),
          ],
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartSensor extends StatelessWidget {
  final List<Map<String, dynamic>> sensorData;
  final String sensorType;

  const ChartSensor({
    super.key,
    required this.sensorData,
    required this.sensorType,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScale = MediaQuery.of(context).textScaleFactor;

    // Data dummy masing-masing sensor
    final dummyTemperature = [
      {"time": "00:04", "value": 27.54},
      {"time": "00:04", "value": 27.60},
      {"time": "00:05", "value": 27.63},
      {"time": "00:05", "value": 27.68},
      {"time": "00:05", "value": 27.65},
      {"time": "00:05", "value": 27.60},
    ];

    final dummyPH = [
      {"time": "00:04", "value": 7.40},
      {"time": "00:04", "value": 7.39},
      {"time": "00:05", "value": 7.32},
      {"time": "00:05", "value": 7.35}, // stabil mendekati target
      {"time": "00:05", "value": 7.32},
      {"time": "00:05", "value": 7.35},
    ];

    final dummySalinity = [
      {"time": "00:04", "value": 25.60},
      {"time": "00:04", "value": 25.45},
      {"time": "00:05", "value": 25.38},
      {"time": "00:05", "value": 25.12},
      {"time": "00:05", "value": 25.09},
      {"time": "00:05", "value": 25.04},
    ];

    final dummyTurbidity = [
      {"time": "00:04", "value": 21.40},
      {"time": "00:04", "value": 21.25},
      {"time": "00:05", "value": 20.90},
      {"time": "00:05", "value": 20.72},
      {"time": "00:05", "value": 20.83},
      {"time": "00:05", "value": 21.11},
    ];

    // Pilih dummy sesuai sensorType
    List<Map<String, dynamic>> dummyData;
    switch (sensorType) {
      case 'temperature':
        dummyData = dummyTemperature;
        break;
      case 'salinity':
        dummyData = dummySalinity;
        break;
      case 'turbidity':
        dummyData = dummyTurbidity;
        break;
      default:
        dummyData = dummyPH;
    }

    final data = dummyData;

    // Ambil nilai tertinggi & terendah dari sensor untuk set minY dan maxY
    final values = data.map((e) => (e["value"] as num).toDouble()).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxValue - minValue) * 0.1; // beri jarak 10%

    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.02),
      child: LineChart(
        LineChartData(
          minY: minValue - yPadding,
          maxY: maxValue + yPadding,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenWidth * 0.08,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.005),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(fontSize: 10 * textScale),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenHeight * 0.03,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.005),
                      child: Text(
                        data[index]["time"],
                        style: TextStyle(fontSize: 10 * textScale),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey),
              bottom: BorderSide(color: Colors.grey),
              right: BorderSide(color: Colors.transparent),
              top: BorderSide(color: Colors.transparent),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value["value"] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.15,
              color: Colors.blue,
              barWidth: screenWidth * 0.007,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withAlpha(50),
              ),
              dotData: FlDotData(show: true), // tampilkan titik
            ),
          ],
        ),
      ),
    );
  }
}
*/




