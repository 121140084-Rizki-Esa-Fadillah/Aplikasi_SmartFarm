class SensorDataStore {
  static final SensorDataStore _instance = SensorDataStore._internal();

  factory SensorDataStore() {
    return _instance;
  }

  SensorDataStore._internal();

  // Menyimpan data sensor terbaru per kolam
  final Map<String, Map<String, dynamic>> sensorDataByPond = {};

  // Menyimpan histori per kolam dan tipe sensor
  final Map<String, Map<String, List<Map<String, dynamic>>>> historyByPond = {};

  /// Memperbarui histori data sensor per kolam
  void updateSensorHistory(String pondId, String sensorType, dynamic value) {
    if (value == null || value is! num) return;

    final now = DateTime.now();
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final entry = {
      "value": value.toDouble(),
      "time": formattedTime,
    };

    // Pastikan struktur nested ada
    historyByPond.putIfAbsent(pondId, () => {});
    historyByPond[pondId]!.putIfAbsent(sensorType, () => []);

    // Tambahkan data ke histori
    historyByPond[pondId]![sensorType]!.add(entry);

    // Batasi panjang histori (misal: 6 data terakhir)
    if (historyByPond[pondId]![sensorType]!.length > 6) {
      historyByPond[pondId]![sensorType]!.removeAt(0);
    }
  }

  /// Set data terbaru sensor per kolam
  void setSensorData(String pondId, Map<String, dynamic> data) {
    sensorDataByPond[pondId] = data;
  }

  /// Ambil data terbaru sensor untuk kolam tertentu
  Map<String, dynamic> getSensorData(String pondId) {
    return sensorDataByPond[pondId] ?? {};
  }

  /// Ambil histori untuk kolam dan jenis sensor tertentu
  List<Map<String, dynamic>> getHistory(String pondId, String sensorType) {
    return historyByPond[pondId]?[sensorType] ?? [];
  }
}
