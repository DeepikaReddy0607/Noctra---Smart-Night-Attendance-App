import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentApprovalScreen extends StatefulWidget {
  final String token;

  const StudentApprovalScreen({super.key, required this.token});

  @override
  State<StudentApprovalScreen> createState() =>
      _StudentApprovalScreenState();
}

class _StudentApprovalScreenState extends State<StudentApprovalScreen> {
  List students = [];
  bool isLoading = true;
  String error = "";

  final String baseUrl = "https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api"; // change if needed

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // ✅ Fetch pending students
  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/pending-students/"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          students = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load students";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Server error";
        isLoading = false;
      });
    }
  }

  // ✅ Approve student
  Future<void> approveStudent(String id) async {
  final url = "$baseUrl/chief-warden/activate-student/$id/";
  print("Calling: $url");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${widget.token}",
      },
    );
    if(!mounted) return;
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      showMessage("Approved");
      fetchStudents();
    } else {
      showMessage("Approval failed: ${response.statusCode}");
    }
  } catch (e) {
    if (!mounted) return;
    print("ERROR: $e");
    showMessage("Server error");
  }
}

  // ❌ Reject student
  Future<void> rejectStudent(String id) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chief-warden/reject-student/$id/"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        fetchStudents();
      } else {
        showMessage("Rejection failed");
      }
    } catch (e) {
      showMessage("Server error");
    }
  }

  void showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Approvals"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchStudents,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error))
                : students.isEmpty
                    ? const Center(child: Text("No pending requests"))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student["name"] ?? "No Name",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Email: ${student["email"]}"),
                                  Text("Roll No: ${student["roll_no"]}"),

                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () => approveStudent(
                                            student["id"]),
                                        child: const Text("Approve"),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () => rejectStudent(
                                            student["id"]),
                                        child: const Text("Reject"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}