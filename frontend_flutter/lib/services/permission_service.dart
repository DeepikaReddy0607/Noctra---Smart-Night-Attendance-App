import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class PermissionService {

  static const base =
  "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/attendance";

  static Future<Map<String, dynamic>> getPermissions() async {

    final token = await TokenService.getAccessToken();

    final res = await http.get(
      Uri.parse("$base/block-warden/permissions/"),
      headers: {"Authorization": "Bearer $token"},
    );
    print(res.statusCode);
    print(res.body);
    final decoded =  jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {
      "pending": [],
      "approved": [],
      "rejected": []
    };
  }

  static Future approve(int id) async {

    final token = await TokenService.getAccessToken();

    await http.post(
      Uri.parse("$base/block-warden/permissions/$id/approve/"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  static Future reject(int id) async {

    final token = await TokenService.getAccessToken();

    await http.post(
      Uri.parse("$base/block-warden/permissions/$id/reject/"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
  static Future<List> getApprovedStudents() async {

    final token = await TokenService.getAccessToken();

    final res = await http.get(
      Uri.parse("$base/caretaker/approved-permissions/"),
      headers: {"Authorization": "Bearer $token"},
    );

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      return decoded;
    }

    return [];
  }
}