import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ApiService {
  //static const String baseUrl = "https://backendsadewasmartfarm-production.up.railway.app/api";
  static const String baseUrl = "http://192.168.242.45:5000/api";

  static Future<bool> login(String username, String password) async {
    try {
      if (fcmDeviceToken == null) {
        print(" Device token belum tersedia.");
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

        // Simpan role
        if (data.containsKey("role")) {
          await prefs.setString("role", data["role"]);
        }

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

  static Future<String?> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/password/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // OTP valid, kirim token ke halaman ResetPassword
        return data["token"];
      } else if (response.statusCode == 401 && data["message"] == "expired") {
        // OTP sudah kedaluwarsa
        return "expired";
      } else {
        // OTP salah atau error lain
        return null;
      }
    } catch (e) {
      // Jika ada kesalahan lain (misalnya koneksi error), anggap gagal
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

  static Future<Map<String, bool>?> checkUsernameEmail(String username, String email) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) return null;

      final response = await http.post(
        Uri.parse("$baseUrl/check/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "username": username,
          "email": email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "usernameExists": data["usernameExists"],
          "emailExists": data["emailExists"],
        };
      } else {
        return null;
      }
    } catch (e) {
      print("Error saat cek username/email: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> checkIdPondNamePond(String idPond, String namePond) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) return null;

      final response = await http.post(
        Uri.parse("$baseUrl/check/kolam"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "idPond": idPond,
          "namePond": namePond,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "idPondExists": data["idPondExists"],
          "namePondExists": data["namePondExists"],
        };
      } else {
        print('Failed to load data');
        return null;
      }
    } catch (e) {
      print("Error saat cek idPond/namePond: $e");
      return null;
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

  static Future<Map<String, dynamic>?> getAerator(String pondId) async {
    final uri = Uri.parse('$baseUrl/konfigurasi/aerator/$pondId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched Aerator: $data"); // Log respons untuk debug
      return data;
    } else {
      throw Exception('Failed to load aerator data');
    }
  }

  static Future<void> updateAerator(String pondId, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/konfigurasi/aerator/$pondId');

    final response = await http.put(
      uri,
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update aerator');
    }
  }

  static Future<Map<String, dynamic>> getFeeding(String pondId) async {
    final response = await http.get(Uri.parse('$baseUrl/konfigurasi/feeding/$pondId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil jadwal feeding: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> updateFeeding(String pondId, Map<String, dynamic> feedingData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/konfigurasi/feeding/$pondId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(feedingData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memperbarui jadwal feeding: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> getMonitoringData(String pondId) async {
    final response = await http.get(Uri.parse('$baseUrl/monitoring/$pondId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load monitoring data');
    }
  }

  static Future<Map<String, dynamic>?> getThresholds(String pondId) async {
    final uri = Uri.parse('$baseUrl/konfigurasi/thresholds/$pondId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched Thresholds: $data"); // Log untuk melihat data respons
      return data;
    } else {
      throw Exception('Failed to load thresholds');
    }
  }

  static Future<void> updateThresholds(String pondId, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/konfigurasi/thresholds/$pondId');

    final response = await http.put(
      uri,
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update thresholds');
    }
  }

  static Future<Map<String, dynamic>?> getNotificationById(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("Error: Token tidak ditemukan.");
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
        print("Gagal mengambil notifikasi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil notifikasi: $e");
      return null;
    }
  }

  static Future<List<dynamic>?> getNotificationsByPondId(String idPond) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("Error: Token tidak ditemukan.");
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
        print("Gagal mengambil notifikasi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil notifikasi berdasarkan idPond: $e");
      return null;
    }
  }

  static Future<bool> markNotificationAsRead(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("Error: Token tidak ditemukan.");
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
        print("Gagal menandai notifikasi sebagai dibaca: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saat memperbarui notifikasi: $e");
      return false;
    }
  }

  static Future<List<dynamic>?> getHistoryByPond(String pondId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("Error: Token tidak ditemukan.");
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
        print("Gagal mengambil riwayat: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil riwayat: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getHistoryById(String historyId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("Error: Token tidak ditemukan.");
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
        print("Gagal mengambil riwayat berdasarkan ID: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil riwayat berdasarkan ID: $e");
      return null;
    }
  }

  static Future<bool> checkEmailDomain(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-email-domain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error cek domain email: $e');
      return false;
    }
  }
}
