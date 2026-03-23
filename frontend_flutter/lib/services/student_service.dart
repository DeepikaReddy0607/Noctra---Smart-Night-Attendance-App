import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'token_service.dart';
class StudentService {
  static const String _baseUrl = "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api";

  static Future<Map<String, dynamic>> assignHostel({
    required String rollNo,
    required String hostel,
    required String block,
    required String roomNumber,
  }) async {
    final token = await TokenService.getAccessToken();
    if(token == null){
      return{
        "status" : 401,
        "body" : {"error": "User not authenticated"},
      };
    }
    final response = await http.post(
      Uri.parse("$_baseUrl/assign-hostel/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "roll_no": rollNo,
        "hostel": hostel,
        "block": block,
        "room_number": roomNumber,
      }),
    ).timeout(const Duration(seconds: 10));

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await TokenService.getAccessToken();

    final res = await http.get(
      Uri.parse("$_baseUrl/students/dashboard/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return {
      "status": res.statusCode,
      "body": jsonDecode(res.body),
    };
  }
  static Future<void> sendEmergency() async {

    final token = await TokenService.getAccessToken();
    print("TOKEN: $token");
    final response = await http.post(
      Uri.parse("$_baseUrl/hostel/emergency/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "message": "Emergency triggered"
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to send emergency");
    }
  }
}
