import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignmentsScreen extends StatefulWidget {
  final String token;
  const AssignmentsScreen({super.key, required this.token});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  List assignments = [];
  List caretakers = [];

  bool isLoading = true;

  String? selectedCaretaker;
  String? selectedBlock;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final headers = {
        "Authorization": "Bearer ${widget.token}",
      };

      final res1 = await http.get(
        Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/list/"),
        headers: headers,
      );

      final res2 = await http.get(
        Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/caretakers/"),
        headers: headers,
      );

      setState(() {
        assignments = jsonDecode(res1.body);
        caretakers = jsonDecode(res2.body);
        isLoading = false;
      });

    } catch (e) {
      print("ERROR: $e");
    }
  }

  /// 🔥 ASSIGN API
  Future<void> assign() async {
    if (selectedCaretaker == null || selectedBlock == null) return;

    final res = await http.post(
      Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/assign/"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "caretaker": selectedCaretaker,
        "block": selectedBlock,
        "date": selectedDate.toIso8601String(),
      }),
    );

    if (res.statusCode == 200) {
      loadData();
      Navigator.pop(context);
    }
  }

  /// 🔥 ASSIGN DIALOG
  void openAssignDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Assign Caretaker"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// CARETAKER DROPDOWN
            DropdownButtonFormField(
              hint: const Text("Select Caretaker"),
              items: caretakers.map((c) {
                return DropdownMenuItem(
                  value: c["id"].toString(),
                  child: Text(c["name"]),
                );
              }).toList(),
              onChanged: (v) => selectedCaretaker = v.toString(),
            ),

            const SizedBox(height: 10),

            /// BLOCK INPUT
            TextField(
              decoration: const InputDecoration(labelText: "Block"),
              onChanged: (v) => selectedBlock = v,
            ),

            const SizedBox(height: 10),

            /// DATE PICKER
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: const Text("Select Date"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: assign, child: const Text("Assign")),
        ],
      ),
    );
  }

  /// 🔥 UI
  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openAssignDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              const Text(
                "Caretaker Assignments",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              /// ASSIGNMENT LIST
              ...assignments.map((a) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(a["caretaker_name"] ?? "Unknown"),
                    subtitle: Text(
                        "Block: ${a["block"]} | Date: ${a["date"]}"),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}