import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/hostel"; // change this

  static Future<List> getViolations(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/violations/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  }

  static Future<List> getApprovedStudents(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/approved-students/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  }

  static Future<List> getLibraryStudents(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/library-monitor/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
        return decoded;
    } else {
        print("API ERROR: $decoded");
        return []; // 👈 prevent crash
    }
  }
}