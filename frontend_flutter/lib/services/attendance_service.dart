import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class AttendanceService {

  static const String baseUrl =
      "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api";

  static Future<Map<String, dynamic>> getBlockAttendance() async {

    final token = await TokenService.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/attendance/block-monitor/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Attendance fetch failed");
  }
  static Future<List> getAttendanceHistory() async {
  final token = await TokenService.getAccessToken();

  final res = await http.get(
    Uri.parse("$baseUrl/attendance/student/history/"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print("ATT STATUS: ${res.statusCode}");
  print("ATT BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Failed to load attendance");
  }

  final data = jsonDecode(res.body);

  if (data is List) return data;

  return [];
}
}