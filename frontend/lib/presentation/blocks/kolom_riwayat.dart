import 'package:flutter/material.dart';
import '../../color/color_constant.dart';
import '../../server/api_service.dart';
import '../widget/input/input_date.dart';
import 'list_riwayat_tambak.dart';

class KolomRiwayat extends StatefulWidget {
  final String namePond;
  final String pondId;


  const KolomRiwayat({super.key, required this.pondId, required this.namePond});

  @override
  _KolomRiwayatState createState() => _KolomRiwayatState();
}

class _KolomRiwayatState extends State<KolomRiwayat> {
  int _currentPage = 0;
  final int itemsPerPage = 7;
  List<Map<String, dynamic>> historyData = []; // Semua data dari API
  List<Map<String, dynamic>> filteredData = []; // Data setelah difilter
  bool isLoading = true;
  bool isFiltered = false; // Untuk menentukan apakah sedang dalam mode filter
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Ambil data saat widget dimuat
  }

  // ✅ Ambil Data Riwayat dari API
  Future<void> _fetchHistory() async {
    setState(() {
      isLoading = true;
    });

    List<dynamic>? response = await ApiService.getHistoryByPond(widget.pondId);

    setState(() {
      if (response != null && response.isNotEmpty) {
        historyData = response.map((item) {
          DateTime parsedDate = DateTime.parse(item["date"]);
          String formattedDate =
              "${parsedDate.day.toString().padLeft(2, '0')}/"
              "${parsedDate.month.toString().padLeft(2, '0')}/"
              "${parsedDate.year}";

          return {
            "id": item["_id"],
            "date": formattedDate,
            "data": item["data"],
          };
        }).toList();
        filteredData = List.from(historyData);
      }
      isLoading = false;
    });
  }

  // ✅ Filter Data Berdasarkan Tanggal
  void _filterData(DateTime date) {
    String formattedDate =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

    List<Map<String, dynamic>> tempFiltered =
    historyData.where((item) => item["date"] == formattedDate).toList();

    setState(() {
      selectedDate = formattedDate;
      filteredData = tempFiltered;
      isFiltered = true;
      _currentPage = 0;
    });
  }

  // ✅ Reset Data ke Semua Data
  void _resetFilter() {
    setState(() {
      filteredData = List.from(historyData);
      selectedDate = null;
      isFiltered = false;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredData.length / itemsPerPage).ceil();
    List<Map<String, dynamic>> displayedData =
    filteredData.skip(_currentPage * itemsPerPage).take(itemsPerPage).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double paddingSize = screenWidth < 350 ? 12.0 : 15.0;

        return Container(
          padding: EdgeInsets.only(
              top: paddingSize * 1.5, left: paddingSize, right: paddingSize),
          decoration: BoxDecoration(
            color: const Color(0x80D9DCD6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Input Tanggal dengan Icon Reset (X)
              Row(
                children: [
                  Text(
                    "Cari Laporan :  ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.primary,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.6,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        InputDate(
                          onDateSelected: _filterData,
                          onReset: _resetFilter, // ✅ Reset filter jika tombol X ditekan
                          showCalendarIcon: !isFiltered,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ✅ Loader jika sedang mengambil data
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (historyData.isEmpty)
                Container(
                  alignment: Alignment.center, // ✅ Menjadikan teks center
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Text(
                    "Belum ada Laporan Riwayat Kualitas Air",
                    textAlign: TextAlign.center, // ✅ Pastikan teks di tengah jika ada lebih dari satu baris
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: displayedData.isEmpty
                            ? Container(
                          alignment: Alignment.center, // ✅ Menjadikan teks center
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text(
                            "Laporan Riwayat Kualitas Air pada Tanggal ${selectedDate ?? ""} tidak tersedia",
                            textAlign: TextAlign.center, // ✅ Pastikan teks di tengah jika ada lebih dari satu baris
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        )
                            : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayedData.length,
                          itemBuilder: (context, index) {
                            var historyItem = displayedData[index];

                            return Column(
                              children: [
                                ListRiwayatTambak(
                                  id: historyItem["id"],
                                  namePond: widget.namePond,
                                  date: historyItem["date"],
                                  onDownloadPressed: () {},
                                  pondId: widget.pondId,
                                ),
                                if (index != displayedData.length - 1)
                                  const Divider(color: Colors.white, thickness: 1),
                              ],
                            );
                          },
                        ),
                      ),

                      // ✅ Divider selalu di atas Pagination
                      const Divider(color: Colors.white, thickness: 1),

                      // ✅ Pagination (tetap muncul meskipun data kosong)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: Color(0xFF16425B), size: 30),
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              "${_currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: Color(0xFF16425B), size: 30),
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
