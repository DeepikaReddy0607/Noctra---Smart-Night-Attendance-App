import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RiskScreen extends StatefulWidget {
  final String token;

  const RiskScreen({super.key, required this.token});

  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  List blocks = [];
  bool isLoading = true;

  final String baseUrl =
      "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api";

  @override
  void initState() {
    super.initState();
    fetchRiskData();
  }

  // 🔹 FETCH REAL DATA
  Future<void> fetchRiskData() async {
    try {
      var res = await http.get(
        Uri.parse("$baseUrl/chief-warden/block-stats/"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (res.statusCode == 200) {
        blocks = jsonDecode(res.body);
      } else {
        print(res.body);
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  // 🔥 RISK LOGIC (REAL)
  String getRisk(dynamic b) {
    int absent = b["absent"] ?? 0;
    int late = b["late"] ?? 0;

    if (absent > 5 || late > 8) return "HIGH";
    if (absent > 2 || late > 3) return "MEDIUM";
    return "LOW";
  }

  Color getColor(String risk) {
    switch (risk) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      case "LOW":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Risk Monitoring")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blocks.isEmpty
              ? const Center(child: Text("No data"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    var b = blocks[index];
                    String risk = getRisk(b);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getColor(risk),
                          child: Text(
                            risk[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text("Block ${b["block"]}"),
                        subtitle: Text(
                            "Present: ${b["present"]}  Late: ${b["late"]}  Absent: ${b["absent"]}"),
                        trailing: Icon(Icons.warning,
                            color: getColor(risk)),
                      ),
                    );
                  },
                ),
    );
  }
}