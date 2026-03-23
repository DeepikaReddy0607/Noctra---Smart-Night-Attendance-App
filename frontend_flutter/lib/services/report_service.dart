import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_service.dart';
class ReportService {
  static const baseUrl = "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/hostel/reports";

  static Future<Map<String, dynamic>> getDailyReport(String token) async {
    final token = await TokenService.getAccessToken();
    print("TOKEN SENT TO API: $token");
    final res = await http.get(
      Uri.parse("$baseUrl/daily/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("DAILY STATUS: ${res.statusCode}");
    print("DAILY BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Daily API failed");
    }
  }

  static Future<List<dynamic>> getMonthlyReport(String token) async {
    final token = await TokenService.getAccessToken();
    print("TOKEN SENT TO API: $token");
    final res = await http.get(
      Uri.parse("$baseUrl/monthly/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("MONTHLY STATUS: ${res.statusCode}");
    print("MONTHLY BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Monthly API failed");
    }
  }

  static Future<List<dynamic>> getViolations(String token) async {
    final token = await TokenService.getAccessToken();
    print("TOKEN SENT TO API: $token");
    final res = await http.get(
      Uri.parse("$baseUrl/violations/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("VIOLATION STATUS: ${res.statusCode}");
    print("VIOLATION BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Violation API failed");
    }
  }
}