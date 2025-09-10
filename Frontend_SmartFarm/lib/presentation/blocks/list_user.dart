import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../server/api_service.dart';
import '../pages/manajemen/user/edit_user.dart';
import '../widget/pop_up/custom_dialog.dart';
import '../widget/pop_up/custom_dialog_button.dart';
import '../widget/pop_up/popup_menu.dart';

class UserList extends StatefulWidget {
  const UserList({required super.key});

  @override
  UserListState createState() => UserListState();
}

class UserListState extends State<UserList> {
  List<Map<String, dynamic>> _users = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void refreshData() {
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x80D9DCD6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      height: 500,
      child: _users.isNotEmpty
          ? ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user, index == 0);
        },
      )
          : const Center(child: Text("Belum ada data")),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isFirstItem) {
    return Builder(
      builder: (cardContext) {
        return Card(
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            top: isFirstItem ? 0 : 6,
            bottom: 6,
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['username'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            user['email'] ?? '-',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCustomMenu(cardContext, user),
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    text: 'Role: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: user['role'] ?? '-',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Tanggal Buat: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: formatTanggal(user['createdAt'] ?? ''),
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomMenu(BuildContext context, Map<String, dynamic> user) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + size.height - 105,
              left: offset.dx + 135, // Adjust to the left of the icon
              child: Material(
                color: Colors.transparent,
                child: PopupMenu(
                  onEdit: () => _editUserPopup(user),
                  onDelete: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                    _deleteUserPopup(user);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _editUserPopup(Map<String, dynamic> user) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EditUser(
        userId: user['_id'],
        username: user['username'],
        email: user['email'],
        role: user['role'],
        onUpdateSuccess: _fetchUsers,
      ),
    ));
  }


  void _deleteUserPopup(Map<String, dynamic> user) {
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
        _showDialog(success, success ? "Pengguna berhasil dihapus" : "Gagal menghapus pengguna");
      },
    );
  }


  void _showDialog(bool isSuccess, String message, {VoidCallback? onComplete}) {
    CustomDialog.show(
      context: context,
      isSuccess: isSuccess,
      message: message,
      onComplete: onComplete,
    );
  }

}
