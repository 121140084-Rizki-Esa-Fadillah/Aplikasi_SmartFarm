import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import '../../server/api_service.dart';
import 'tile_profile.dart';

class MainHeader extends StatefulWidget {
  const MainHeader({super.key});

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  late String _currentTime = '';
  late String _currentDate = '';
  late Timer _timer;

  String? username;
  String? role;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadUserProfile();
  }

  void _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat.Hms().format(now);
      _currentDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null) {
      setState(() {
        username = profile['username'] ?? 'Pengguna';
        role = profile['role'] ?? 'User';
      });
    } else {
      setState(() {
        username = 'Unknown';
        role = 'User';
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentTime,
                    style: TextStyle(
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _currentDate,
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              TileProfile(
                username: username ?? ' ',
                role: role ?? ' ',
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            color: Colors.white,
            thickness: 2,
          ),
        ),
      ],
    );
  }
}
