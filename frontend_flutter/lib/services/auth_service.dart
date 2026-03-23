import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class AuthService {

  // =========================
  // BASE URLS
  // =========================

  static const String authBase =
      "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/auth";

  static const String attendanceBase =
      "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/attendance";
  static const String baseUrl = "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/";
  // =========================
  // LOGIN
  // =========================

  static Future<Map<String, dynamic>> login({
    required String rollNo,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$authBase/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roll_no": rollNo,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 10));

    return _processResponse(response);
  }
  static Future<Map<String, dynamic>> getCaretakerDashboard() async {

  final token = await TokenService.getAccessToken();

  final response = await http.get(
    Uri.parse("$attendanceBase/caretaker/dashboard/"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  ).timeout(const Duration(seconds: 10));
  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");
  return _processResponse(response);
}


  // =========================
  // VERIFY OTP
  // =========================

  static Future<Map<String, dynamic>> verifyOtp({
    required String rollNo,
    required String otp,
  }) async {

    final response = await http.post(
      Uri.parse("$authBase/verify-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roll_no": rollNo,
        "otp": otp,
      }),
    ).timeout(const Duration(seconds: 10));

    return _processResponse(response);
  }
  static Future<Map<String, dynamic>> resendOtp(String rollNo) async {
  final response = await http.post(
    Uri.parse("$baseUrl/resend-otp/"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "roll_no": rollNo,
    }),
  );

  return {
    "status": response.statusCode,
    "body": jsonDecode(response.body),
  };
}

  // =========================
  // REGISTER STUDENT
  // =========================

  static Future<Map<String, dynamic>> register({
    required String rollNo,
    required String email,
    required String phone,
    required String password,
    required String block,
    required String roomNumber,
    required String cotNumber,
    required String year,
  }) async {

    final response = await http.post(
      Uri.parse("$authBase/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roll_no": rollNo,
        "email": email,
        "phone": phone,
        "password": password,
        "block": block,
        "room_number": roomNumber,
        "cot_number": cotNumber,
        "year": year,
      }),
    ).timeout(const Duration(seconds: 10));

    return _processResponse(response);
  }

  // =========================
  // MARK ATTENDANCE
  // =========================

  static Future<Map<String, dynamic>> markAttendance({
    required double latitude,
    required double longitude,
  }) async {
    print("API FUNCTION CALLED");
    final token = await TokenService.getAccessToken();
    print("TOKEN: $token");
    final response = await http.post(
      Uri.parse("$attendanceBase/mark/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "latitude": latitude,
        "longitude": longitude,
      }),
    ).timeout(const Duration(seconds: 10));
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    return _processResponse(response);
  }

  // =========================
  // ATTENDANCE HISTORY
  // =========================

  static Future<Map<String, dynamic>> getAttendanceHistory() async {

    final token = await TokenService.getAccessToken();

    final response = await http.get(
      Uri.parse("$attendanceBase/history/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 10));

    return _processResponse(response);
  }

  // =========================
  // RESPONSE HANDLER
  // =========================

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      return {
        "status": response.statusCode,
        "body": decoded,
      };

    } catch (_) {

      return {
        "status": response.statusCode,
        "body": {"error": "Invalid server response"},
      };
    }
  }
}