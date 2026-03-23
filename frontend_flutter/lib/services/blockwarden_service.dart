import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class BlockWardenService {

  static Future<Map<String, dynamic>> getDashboard() async {

    final token = await TokenService.getAccessToken();

    final response = await http.get(
      Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/attendance/block-warden/dashboard/"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to load dashboard");
  }
}