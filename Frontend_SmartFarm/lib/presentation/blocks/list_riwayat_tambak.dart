import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../../server/api_service.dart';
import '../pages/monitoring/riwayat_kualitas_air/laporan_kualitas_air.dart';
import '../widget/button/button_detail.dart';
import '../widget/pop_up/custom_dialog.dart';

class ListRiwayatTambak extends StatefulWidget {
  final String id;
  final String pondId;
  final String namePond;
  final String date;
  final VoidCallback onDownloadPressed;

  const ListRiwayatTambak({
    super.key,
    required this.id,
    required this.pondId,
    required this.date,
    required this.onDownloadPressed,
    required this.namePond,
  });

  @override
  _ListRiwayatTambakState createState() => _ListRiwayatTambakState();
}

class _ListRiwayatTambakState extends State<ListRiwayatTambak> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double textSize = constraints.maxWidth < 350 ? 12 : 14;
        double iconSize = constraints.maxWidth < 350 ? 20.0 : 22.0;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${widget.namePond} ${widget.date}',
                  style: GoogleFonts.inter(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16425B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  ButtonDetail(
                    text: 'Lihat Detail',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LaporanKualitasAir(
                            date: widget.date,
                            pondId: widget.pondId,
                            historyId: widget.id,
                            namePond: widget.namePond,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        isPressed = true;
                      });

                      await downloadLaporanExcel(widget.id, widget.namePond, widget.date, context);

                      setState(() {
                        isPressed = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPressed ? Colors.blue.withAlpha(50) : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.download,   // bawaan Flutter
                        color: isPressed ? Colors.blue : const Color(0xFF16425B),
                        size: iconSize,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> downloadLaporanExcel(
    String historyId, String namePond, String date, BuildContext context) async {
  try {
    debugPrint("Mulai mengunduh laporan: $namePond - $date");

    String safeDate = date.replaceAll("/", "-");

    if (Platform.isAndroid) {
      if (await isAndroid10OrAbove()) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Izin penyimpanan diperlukan untuk menyimpan laporan."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Izin penyimpanan diperlukan untuk menyimpan laporan."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    final response = await ApiService.getHistoryById(historyId);
    if (response == null || response["data"] == null) {
      debugPrint("Gagal mengambil data laporan dari API.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil data laporan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> laporanData = (response["data"] as List)
        .map((item) => {
      "Waktu": item["time"] ?? "-",
      "Suhu (°C)": (item["temperature"] as num?)?.toStringAsFixed(1) ?? "0.0",
      "pH": (item["ph"] as num?)?.toStringAsFixed(1) ?? "0.0",
      "Salinitas (ppt)": (item["salinity"] as num?)?.toStringAsFixed(1) ?? "0.0",
      "Kekeruhan (NTU)": (item["turbidity"] as num?)?.toStringAsFixed(1) ?? "0.0",
      "Hujan": item["rain_status"] == true ? "Ya" : "Tidak",
    })
        .toList();

    var excel = Excel.createExcel();
    Sheet sheet = excel['Laporan_Kualitas_Air'];

    List<String> headers = laporanData.first.keys.toList();
    sheet.appendRow(headers);

    for (var row in laporanData) {
      sheet.appendRow(row.values.toList());
    }

    // Simpan file ke folder Download menggunakan MediaStore API
    debugPrint("Menyimpan file menggunakan MediaStore API...");
    File? file = await saveFileToDownloadsWithMediaStore(excel, namePond, safeDate);

    if (file != null) {
      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Laporan berhasil disimpan\n Lokasi file : ${file.path}",
      );
      debugPrint("Laporan berhasil disimpan di: ${file.path}");
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "File gagal disimpan.",
      );
      debugPrint("File gagal disimpan.");
    }
  } catch (e) {
    debugPrint("Error saat mendownload laporan: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error saat mendownload laporan: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<File?> saveFileToDownloadsWithMediaStore(Excel excel, String namePond, String safeDate) async {
  try {
    List<int>? excelBytes = excel.encode();
    if (excelBytes == null) {
      debugPrint("Gagal mengonversi Excel ke bytes.");
      return null;
    }
    Uint8List bytes = Uint8List.fromList(excelBytes);

    final fileName = "Laporan_${namePond}_$safeDate.xlsx";
    final directory = Directory("/storage/emulated/0/Download");

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath = "${directory.path}/$fileName";
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    debugPrint("File berhasil disimpan dengan MediaStore: $filePath");
    return file;
  } catch (e) {
    debugPrint("Error saat menyimpan file dengan MediaStore: $e");
    return null;
  }
}

Future<bool> isAndroid10OrAbove() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 29;
  }
  return false;
}