import 'package:flutter/material.dart';
import '../../../../color/color_constant.dart';
import '../../../server/api_service.dart';

class LaporanTable extends StatefulWidget {
  final String id;

  const LaporanTable({super.key, required this.id});

  @override
  _LaporanTableState createState() => _LaporanTableState();
}

class _LaporanTableState extends State<LaporanTable> {
  final ScrollController _verticalController = ScrollController();

  Future<List<Map<String, dynamic>>> _fetchLaporanData() async {
    try {
      if (widget.id.isEmpty) return []; // Cegah request jika id kosong

      final response = await ApiService.getHistoryById(widget.id);
      if (response != null && response["data"] is List) {
        return (response["data"] as List)
            .map((item) => {
          "waktu": item["time"] ?? "-",
          "suhu": (item["temperature"] as num?)?.toStringAsFixed(1) ?? "0.0",
          "ph": (item["ph"] as num?)?.toStringAsFixed(1) ?? "0.0",
          "salinitas": (item["salinity"] as num?)?.toStringAsFixed(1) ?? "0.0",
          "kekeruhan": (item["turbidity"] as num?)?.toStringAsFixed(1) ?? "0.0",
          "hujan": item["rain_status"] ?? false,
        })
            .toList();
      }
    } catch (e) {
      debugPrint("❌ Error fetching data: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 475,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tabel (Tetap)
          Container(
            color: ColorConstant.primary,
            child: Table(
              border: TableBorder.all(color: Colors.white),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell("Waktu"),
                    _buildHeaderCell("Suhu\n(°C)"),
                    _buildHeaderCell("pH"),
                    _buildHeaderCell("Salinitas\n(PPT)"),
                    _buildHeaderCell("Kekeruhan\n(NTU)"),
                    _buildHeaderCell("Hujan"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Isi Tabel (Scroll Vertikal)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchLaporanData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Data tidak tersedia"));
                }

                List<Map<String, dynamic>> laporanData = snapshot.data!;

                return Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    child: Table(
                      border: TableBorder.all(color: Colors.grey.shade400),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(2.5),
                        5: FlexColumnWidth(1.5),
                      },
                      children: laporanData.map((data) {
                        return TableRow(
                          decoration: const BoxDecoration(color: Colors.white),
                          children: [
                            _buildDataCell(data["waktu"]),
                            _buildDataCell(data["suhu"]),
                            _buildDataCell(data["ph"]),
                            _buildDataCell(data["salinitas"]),
                            _buildDataCell(data["kekeruhan"]),
                            _buildDataCell(_convertHujanToText(data["hujan"])),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget header cell
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Widget data cell
  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Konversi hujan dari bool ke string
  String _convertHujanToText(bool? value) {
    return value == true ? "Ya" : "Tidak";
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }
}
