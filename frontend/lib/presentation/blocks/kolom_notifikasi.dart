import 'package:flutter/material.dart';
import '../../color/color_constant.dart';
import '../../server/api_service.dart';
import 'dart:async';


class KolomNotifikasi extends StatefulWidget {
  final String pondId;
  const KolomNotifikasi({super.key, required this.pondId});

  @override
  _KolomNotifikasiState createState() => _KolomNotifikasiState();
}

class _KolomNotifikasiState extends State<KolomNotifikasi> {
  List<Map<String, dynamic>> notifikasiList = [];
  Map<String, dynamic>? selectedNotification;
  int _currentPage = 0;
  static const int itemsPerPage = 6;
  int? _selectedIndex;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();

    // 🔄 Timer untuk auto-refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }


  Future<void> _fetchNotifications() async {
    final notifications = await ApiService.getNotificationsByPondId(widget.pondId);
    if (notifications != null) {
      setState(() {
        notifikasiList = notifications.map<Map<String, dynamic>>((notif) {
          String jenis = _getNotificationType(notif["type"]);
          Color warna = jenis == "Peringatan" ? Colors.red : Colors.amber;
          return {
            "id": notif["_id"],
            "jenis": jenis,
            "judul": notif["title"] ?? "Notifikasi",
            "waktu": _formatTime(notif["time"]),
            "message": notif["message"] ?? "Tidak ada pesan",
            "warna": warna,
            "status": notif["status"] ?? "unread", // ✅ Tambahkan status read/unread dari API
          };
        }).toList();
      });
    }
  }

  Future<void> _fetchNotificationDetail(String id, int index) async {
    final notifDetail = await ApiService.getNotificationById(id);
    if (notifDetail != null) {
      String jenis = _getNotificationType(notifDetail["type"]);
      Color warna = jenis == "Peringatan" ? Colors.red : Colors.amber;

      int globalIndex = _currentPage * itemsPerPage + index;

      setState(() {
        selectedNotification = {
          "jenis": jenis,
          "judul": notifDetail["title"] ?? "Notifikasi",
          "message": notifDetail["message"] ?? "Tidak ada pesan",
          "warna": warna,
        };
        _selectedIndex = globalIndex;
      });

      // Memanggil fungsi untuk menandai notifikasi sebagai sudah dibaca
      bool success = await ApiService.markNotificationAsRead(id);
      if (success) {
        setState(() {
          notifikasiList[globalIndex]["status"] = "read"; // ✅ Ubah status menjadi "read"
        });

        // Memanggil ulang untuk memperbarui data
        await _fetchNotifications();
      }
    }
  }

  String _formatTime(String timestamp) {
    DateTime notifTime = DateTime.parse(timestamp).toLocal();
    Duration difference = DateTime.now().difference(notifTime);

    if (difference.inMinutes < 1) {
      return "Baru saja";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} menit yang lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} jam yang lalu";
    } else {
      return "${difference.inDays} hari yang lalu";
    }
  }

  String _getNotificationType(String? type) {
    const warningTypes = ["feed_alert", "water_quality_alert"];
    const infoTypes = ["feed_schedule_update", "aerator_control_update", "threshold_update"];

    if (warningTypes.contains(type)) return "Peringatan";
    if (infoTypes.contains(type)) return "Pemberitahuan";
    return "Pemberitahuan";
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = _currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, notifikasiList.length);
    List<Map<String, dynamic>> currentNotifikasi = notifikasiList.sublist(startIndex, endIndex);

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 15, right: 10),
      decoration: BoxDecoration(
        color: const Color(0x80D9DCD6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // ✅ List Notifikasi
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(bottom: BorderSide(color: Colors.white)),
                    ),
                    child: notifikasiList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                      itemCount: currentNotifikasi.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white, height: 1),
                      itemBuilder: (context, index) {
                        final notif = currentNotifikasi[index];

                        // ✅ Hitung index global
                        int globalIndex = _currentPage * itemsPerPage + index;

                        bool isSelected = _selectedIndex == globalIndex;

                        return Material(
                          color: isSelected ? const Color(0x80D9DCD6) : Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 4),
                            title: Text(
                              "[${notif["jenis"]}]\n${notif["judul"]}",
                              style: TextStyle(
                                color: notif["status"] == "unread" ? ColorConstant.primary : Colors.white, // ✅ Perubahan warna
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            subtitle: Text(
                              notif["waktu"],
                              style: TextStyle(fontSize: 11, color: ColorConstant.primary),
                            ),
                            onTap: () => _fetchNotificationDetail(notif["id"], index),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Container(width: 1, color: Colors.white),

                // ✅ Detail Notifikasi (Dikembalikan ke Format Asli)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(bottom: BorderSide(color: Colors.white)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Hi, OwnerTambak",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorConstant.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text("Ada pemberitahuan baru untuk anda", style: TextStyle(fontSize: 12, color: ColorConstant.primary)),
                        ),
                        const SizedBox(height: 6),
                        const Divider(color: Colors.white),
                        selectedNotification != null
                            ? Padding(
                          padding: const EdgeInsets.only(left: 10, top: 15),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      selectedNotification!["jenis"] == "Peringatan"
                                          ? Icons.warning_amber_rounded
                                          : Icons.notifications,
                                      color: selectedNotification!["warna"],
                                      size: 18,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: "[${selectedNotification!["jenis"]}]\n",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: selectedNotification!["warna"]),
                                ),
                                TextSpan(
                                  text: "\n${selectedNotification!["judul"]}",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColorConstant.primary),
                                ),
                                TextSpan(
                                  text: "\n\n${selectedNotification!["message"]}",
                                  style: TextStyle(fontSize: 13, color: ColorConstant.primary),
                                ),
                              ],
                            ),
                          ),
                        )
                            : const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("Pilih notifikasi untuk melihat detail", style: TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF16425B), size: 30),
                onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
              ),
              Container(
                width: 50, // ✅ Atur lebar agar lebih panjang
                alignment: Alignment.center, // ✅ Pusatkan teks di dalam container
                child: Text(
                  "${_currentPage + 1} / ${(notifikasiList.length / itemsPerPage).ceil()}",
                  style: const TextStyle(
                    color: Colors.white, // ✅ Warna putih
                    fontWeight: FontWeight.w600, // ✅ Font-weight 600
                    fontSize: 14, // ✅ Ukuran font (opsional)
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF16425B), size: 30),
                onPressed: _currentPage < (notifikasiList.length / itemsPerPage).ceil() - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
