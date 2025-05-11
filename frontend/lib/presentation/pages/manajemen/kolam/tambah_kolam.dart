import 'package:flutter/material.dart';
import '../../../../server/api_service.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/button/button_filled.dart';
import '../../../widget/input/input_standart.dart';
import '../../../widget/pop_up/custom_dialog.dart';

class TambahKolam extends StatefulWidget {
  final VoidCallback onKolamAdded; //

  const TambahKolam({super.key, required this.onKolamAdded});

  @override
  State<TambahKolam> createState() => _TambahKolamState();
}

class _TambahKolamState extends State<TambahKolam> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _simpanKolam() async {
    String idPond = _idController.text.trim();
    String namePond = _nameController.text.trim();

    if (idPond.isEmpty || namePond.isEmpty) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "ID dan Nama Kolam tidak boleh kosong!",
      );
      return;
    }

    if (namePond.length < 4 || namePond.length > 12) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Nama Kolam harus antara 4 hingga 12 karakter!",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Pengecekan apakah idPond dan namePond sudah ada
    final checkResult = await ApiService.checkIdPondNamePond(idPond, namePond);

    if (checkResult == null) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal memeriksa ketersediaan ID Kolam atau Nama Kolam.",
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Jika ID Kolam atau Nama Kolam sudah ada
    if (checkResult["idPondExists"] == true && checkResult["namePondExists"] == true) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "ID Kolam dan Nama Kolam sudah digunakan, harap gunakan ID Kolam dan Nama Kolam yang lain.",
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (checkResult["idPondExists"] == true) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "ID Kolam sudah digunakan, harap gunakan ID Kolam yang lain.",
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (checkResult["namePondExists"] == true) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Nama Kolam sudah digunakan, harap gunakan Nama Kolam yang lain.",
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Jika ID dan Nama Kolam belum digunakan, lanjutkan untuk menyimpan kolam
    bool success = await ApiService.addKolam(idPond, namePond);

    setState(() {
      _isLoading = false;
    });

    CustomDialog.show(
      context: context,
      isSuccess: success,
      message: success ? "Kolam berhasil ditambahkan" : "Gagal menambahkan kolam. Coba lagi!",
      onComplete: () {
        if (success) {
          widget.onKolamAdded();
          Navigator.pop(context);
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Tambah Kolam",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputStandart(label: "ID Kolam", controller: _idController),
                        InputStandart(label: "Nama Kolam", controller: _nameController),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ButtonFilled(
                    text: "Simpan",
                    onPressed: _isLoading ? () {} : _simpanKolam,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

