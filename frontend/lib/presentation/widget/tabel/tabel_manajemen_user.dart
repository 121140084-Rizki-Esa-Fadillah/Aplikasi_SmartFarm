import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../server/api_service.dart';
import '../../pages/manajemen/user/edit_user.dart';
import '../pop_up/custom_dialog.dart';
import '../pop_up/custom_dialog_button.dart';
import '../../../color/color_constant.dart'; // pastikan path ini benar

class UserManagementTable extends StatefulWidget {
  const UserManagementTable({super.key});

  @override
  State<UserManagementTable> createState() => UserManagementTableState();
}

class UserManagementTableState extends State<UserManagementTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  void refreshData() {
    _fetchUsers();
  }

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    List<Map<String, dynamic>> fetchedUsers = await ApiService.getUsers();
    setState(() {
      _users = fetchedUsers;
    });
  }

  String formatTanggal(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return "Format Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalController,
          child: SizedBox(
            width: 600, // Total lebar tabel, bisa diatur sesuai kebutuhan
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  color: ColorConstant.primary,
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade400),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildHeaderCell("Username"),
                          _buildHeaderCell("Email"),
                          _buildHeaderCell("Role"),
                          _buildHeaderCell("Tanggal Buat"),
                          _buildHeaderCell("Action"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // Body
                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade400),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1.5),
                          4: FlexColumnWidth(2),
                        },
                        children: _users.isNotEmpty
                            ? _users.map((user) {
                          return TableRow(
                            decoration: const BoxDecoration(color: Colors.white),
                            children: [
                              _buildDataCell(user['username'] ?? "-"),
                              _buildDataCell(user['email'] ?? "-"),
                              _buildDataCell(user['role'] ?? "-"),
                              _buildDataCell(formatTanggal(user['createdAt'] ?? "")),
                              _buildActionCell(user),
                            ],
                          );
                        }).toList()
                            : [
                          TableRow(
                            children: [
                              for (int i = 0; i < 5; i++)
                                _buildDataCell("Belum ada data"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(Icons.edit, Colors.green, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditUser(
                  userId: user['_id'],
                  username: user['username'],
                  email: user['email'],
                  role: user['role'],
                  onUpdateSuccess: _fetchUsers,
                ),
              ),
            );
          }),
          const SizedBox(width: 24),
          _buildActionButton(Icons.delete, Colors.red, () {
            _deleteUser(user);
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 30,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onTap,
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    CustomDialogButton.show(
      context: context,
      title: "Konfirmasi Hapus",
      message: "Apakah Anda yakin ingin menghapus pengguna ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      isWarning: true,
      onConfirm: () async {
        bool success = await ApiService.deleteUser(user['_id']);
        if (success) _fetchUsers();
        CustomDialog.show(
          context: context,
          isSuccess: success,
          message: success ? "Pengguna berhasil dihapus" : "Gagal menghapus pengguna",
        );
      },
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }
}
