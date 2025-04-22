import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ApiService {
  static const String baseUrl = "http://192.168.60.45:5000/api";

  static Future<bool> login(String username, String password) async {
    try {
      if (fcmDeviceToken == null) {
        print("⚠️ Device token belum tersedia.");
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'deviceToken': fcmDeviceToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") != null;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token != null) {
      await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    }

    await prefs.remove("token");
  }

  static Future<bool> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/password/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return response.statusCode == 200;
  }

  // **2. Verifikasi OTP**
  static Future<String?> verifyOTP(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/password/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    } else {
      return null;
    }
  }

  // **3. Reset Password**
  static Future<bool> resetPassword(String token, String newPassword) async {
    print("Mengirim token: '$token'");
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/password/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "newPassword": newPassword}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error saat reset password: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) return null;

      final response = await http.get(
        Uri.parse("$baseUrl/users/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error saat mengambil profile: $e");
      return null;
    }
  }

  static Future<bool> editProfile(String username, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return false;

    final response = await http.put(
      Uri.parse("$baseUrl/users/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "username": username,
        "email": email,
      }),
    );

    return response.statusCode == 200;
  }
  static Future<List<Map<String, dynamic>>> getUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/users/manajemenUsers"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      return [];
    }
  }

  static Future<bool> deleteUser(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("$baseUrl/users/manajemenUsers/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error saat menghapus user: $e");
      return false;
    }
  }

  static Future<bool> editUser(String userId, String username, String email, String role) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) return false;

      final response = await http.put(
        Uri.parse("$baseUrl/users/manajemenUsers/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "username": username,
          "email": email,
          "role": role,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error saat edit user: $e");
      return false;
    }
  }


  static Future<bool> addUser(String username, String email, String password, String role) async {
    final url = Uri.parse("$baseUrl/users/manajemenUsers");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      "role": role,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getKolam() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/kolam"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data["data"]);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addKolam(String idPond, String namePond) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("$baseUrl/kolam"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "idPond": idPond,
          "namePond": namePond,
          "statusPond": "Aktif",
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> editKolam(
      String id, String pondId, String name, String status) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        return null;
      }

      final response = await http.put(
        Uri.parse("$baseUrl/kolam/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "pond_id": pondId,
          "name": name,
          "status": status,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));

        return {
          "id": responseData["id"] ?? id,
          "idPond": responseData["idPond"] ?? "",
          "namePond": responseData["namePond"] ?? name,
          "statusPond": responseData["statusPond"] ?? status,
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteKolam(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/kolam/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getDeviceConfig(String pondId, [String? keyPath]) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        return null;
      }

      // Jika keyPath diberikan, tambahkan ke URL
      String endpoint = keyPath != null ? "$baseUrl/konfigurasi/$pondId/$keyPath" : "$baseUrl/konfigurasi/$pondId";

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📩 GET Request API: $endpoint");
      print("📥 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Periksa tipe dari 'data'
        var data = responseData["data"];

        // Jika 'data' adalah Map, kembalikan sebagai Map
        if (data is Map<String, dynamic>) {
          return data;
        }

        // Jika 'data' adalah tipe lain (misalnya int, double, string, bool), kembalikan sebagai Map dengan satu key
        else if (data != null) {
          return {"data": data};
        }

        // Jika 'data' adalah null, kembalikan null
        else {
          print("⚠️ Error: Data tidak ditemukan atau null.");
          return null;
        }
      } else {
        print("Gagal mendapatkan konfigurasi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, stacktrace) {
      print("❌ Error saat mengambil konfigurasi: $e");
      print(stacktrace);
      return null;
    }
  }


  // ✅ Fungsi untuk memperbarui konfigurasi perangkat
  static Future<bool> updateDeviceConfig(String pondId, String keyPath, dynamic newValue) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return false;
      }

      // Pastikan keyPath tidak memiliki "/" di awal atau akhir
      keyPath = keyPath.replaceAll(RegExp(r'^/|/$'), '');

      // Pastikan newValue sesuai dengan tipe yang dapat dikirim
      dynamic requestBody;
      if (newValue is Map || newValue is List) {
        requestBody = jsonEncode(newValue);
      } else {
        requestBody = jsonEncode(newValue); // Kirim newValue langsung tanpa tambahan objek pembungkus
      }

      final response = await http.patch(
        Uri.parse("$baseUrl/konfigurasi/$pondId/$keyPath"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: requestBody,
      );

      print("📩 Request API: PATCH /konfigurasi/$pondId/$keyPath");
      print("📤 Body: $requestBody");
      print("📥 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error saat memperbarui konfigurasi: $e");
      return false;
    }
  }
  static Future<Map<String, dynamic>?> getMonitoringData(String pondId, String sensorType) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return null;
      }

      // 🔹 Buat URL berdasarkan sensorType (jika ada)
      String url = "$baseUrl/monitoring/$pondId";
      if (sensorType != null) {
        url += "/${sensorType.toLowerCase()}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📩 GET Request API: $url");
      print("📥 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // ✅ Berhasil mendapatkan data
      } else {
        print("⚠️ Gagal mendapatkan data monitoring: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, stacktrace) {
      print("❌ Error saat mengambil data monitoring: $e");
      print(stacktrace);
      return null;
    }
  }

  // ✅ Ambil Notifikasi Berdasarkan ID
  static Future<Map<String, dynamic>?> getNotificationById(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/notifikasi/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("⚠️ Gagal mengambil notifikasi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error saat mengambil notifikasi: $e");
      return null;
    }
  }

  // ✅ Ambil Notifikasi Berdasarkan idPond
  static Future<List<dynamic>?> getNotificationsByPondId(String idPond) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/notifikasi/pond/$idPond"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("⚠️ Gagal mengambil notifikasi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error saat mengambil notifikasi berdasarkan idPond: $e");
      return null;
    }
  }

  // ✅ Tandai Notifikasi sebagai "Read"
  static Future<bool> markNotificationAsRead(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return false;
      }

      final response = await http.patch(
        Uri.parse("$baseUrl/notifikasi/$id/read"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("⚠️ Gagal menandai notifikasi sebagai dibaca: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error saat memperbarui notifikasi: $e");
      return false;
    }
  }


  // ✅ Ambil riwayat berdasarkan pondId
  static Future<List<dynamic>?> getHistoryByPond(String pondId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/history/pond?idPond=$pondId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("⚠️ Gagal mengambil riwayat: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error saat mengambil riwayat: $e");
      return null;
    }
  }

  // ✅ Ambil riwayat berdasarkan ID
  static Future<Map<String, dynamic>?> getHistoryById(String historyId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("❌ Error: Token tidak ditemukan.");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/history/id?id=$historyId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("⚠️ Gagal mengambil riwayat berdasarkan ID: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error saat mengambil riwayat berdasarkan ID: $e");
      return null;
    }
  }
}
