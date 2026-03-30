import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViolationsScreen extends StatefulWidget {
  final String token;
  const ViolationsScreen({super.key, required this.token});

  @override
  State<ViolationsScreen> createState() => _ViolationsScreenState();
}

class _ViolationsScreenState extends State<ViolationsScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final res = await http.get(
        Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/violations/"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      final decoded = jsonDecode(res.body);

      setState(() {
        data = decoded;
        isLoading = false;
      });

    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  List safeList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    return [];
  }

  /// 🔥 MODERN CARD SECTION
  Widget buildSection(String title, List list, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  "$title (${list.length})",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// EMPTY STATE
            if (list.isEmpty)
              const Text("No records", style: TextStyle(color: Colors.grey)),

            /// STUDENT LIST
            ...list.map((s) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(Icons.person, color: color),
                  ),
                  title: Text(
                    s["student__roll_no"] ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return const Center(child: Text("No data available"));
    }

    final late = safeList(data!["late"]);
    final left = safeList(data!["left"]);
    final absent = safeList(data!["absent"]);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// TITLE
            const Text(
              "Violations Monitor",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// SECTIONS
            buildSection("Late Students", late, Colors.orange, Icons.access_time),
            buildSection("Left Block", left, Colors.red, Icons.exit_to_app),
            buildSection("Absent Students", absent, Colors.blue, Icons.cancel),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}