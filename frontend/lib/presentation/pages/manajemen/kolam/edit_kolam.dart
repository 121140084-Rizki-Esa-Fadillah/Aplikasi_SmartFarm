import 'package:flutter/material.dart';
import 'package:frontend_app/server/api_service.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/button/button_filled.dart';
import '../../../widget/input/input_standart.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/input/input_status.dart';
import '../../../widget/pop_up/custom_dialog.dart';

class EditKolam extends StatefulWidget {
  final String id;
  final String pondId;
  final String pondName;
  final String status;

  const EditKolam({
    super.key,
    required this.id,
    required this.pondId,
    required this.pondName,
    required this.status,
  });

  @override
  State<EditKolam> createState() => _EditKolamState();
}

class _EditKolamState extends State<EditKolam> {
  late TextEditingController nameController;
  String? selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.pondName);
    selectedStatus = widget.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _updateKolam() async {
    String newName = nameController.text.trim();
    String newStatus = selectedStatus ?? "Aktif";

    // Validasi nama kolam
    if (newName.isEmpty) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Nama kolam tidak boleh kosong",
      );
      return;
    }

    if (newName.length < 4 || newName.length > 12) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Nama kolam harus antara 4 hingga 12 karakter",
      );
      return;
    }

    // Pengecekan apakah nama kolam sudah ada menggunakan API checkIdPondNamePond
    final result = await ApiService.checkIdPondNamePond(widget.pondId, newName);

    if (result == null) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal memeriksa nama kolam, coba lagi.",
      );
      return;
    }

    // Jika nama kolam sudah ada pada kolam lain
    if (result["namePondExists"] == true) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Nama kolam sudah digunakan, harap gunakan nama kolam yang lain.",
      );
      return;
    }

    setState(() => _isLoading = true);

    // Kirim permintaan pembaruan kolam ke API
    var updatedKolam = await ApiService.editKolam(widget.id, widget.pondId, newName, newStatus);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (updatedKolam != null) {
      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Kolam berhasil diperbarui!",
        onComplete: () {
          Navigator.pop(context, updatedKolam);
        },
      );
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal memperbarui kolam. Coba lagi.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Edit ${widget.pondName}",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        InputStandart(
                          label: "Nama Kolam",
                          controller: nameController,
                        ),

                        // ✅ Pastikan ada nilai default
                        InputStatus(
                          initialValue: selectedStatus ?? "Aktif",
                          onChanged: (newStatus) {
                            setState(() {
                              selectedStatus = newStatus;
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ButtonFilled(
                    text: "Simpan",
                    isFullWidth: true,
                    onPressed: _isLoading ? () {} : _updateKolam,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
