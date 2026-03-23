import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class StudentPermissionService {
  static const base =
      "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/attendance";

  /// GET - fetch my permissions
  static Future<List> getMyPermissions() async {
    final token = await TokenService.getAccessToken();

    final res = await http.get(
      Uri.parse("$base/student/permissions/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to load permissions");
    }

    final data = jsonDecode(res.body);

    if (data is List) return data;

    return [];
  }

  /// POST - apply permission
  static Future<void> applyPermission({
    required String type,
    required String date,
  }) async {
    final token = await TokenService.getAccessToken();

    final res = await http.post(
      Uri.parse("$base/student/permissions/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "permission_type": type,
        "date": date,
      }),
    );

    print("POST STATUS: ${res.statusCode}");
    print("POST BODY: ${res.body}");

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Failed to apply permission");
    }
  }
}