import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class ApprovedStudentsScreen extends StatefulWidget {
  const ApprovedStudentsScreen({super.key});

  @override
  State<ApprovedStudentsScreen> createState() => _ApprovedStudentsScreenState();
}

class _ApprovedStudentsScreenState extends State<ApprovedStudentsScreen> {

  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {

    final data = await PermissionService.getApprovedStudents();

    if (!mounted) return;

    setState(() {
      students = data;
      loading = false;
    });
  }

  Color getTypeColor(String type) {
    if (type == "LIBRARY") return Colors.blue;
    if (type == "OUTING") return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Approved Students"),
      ),

      body: students.isEmpty
          ? const Center(child: Text("No approved permissions"))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: students.length,
              itemBuilder: (context, i) {

                final s = students[i];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(14),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// STUDENT INFO
                        Row(
                          children: [

                            const CircleAvatar(
                              radius: 22,
                              child: Icon(Icons.person),
                            ),

                            const SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  s["roll_no"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                Text(
                                  "${s["block"]} • Room ${s["room"]} • Cot ${s["cot"]}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// PERMISSION INFO
                        Row(
                          children: [

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),

                              decoration: BoxDecoration(
                                color: getTypeColor(s["type"]).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                s["type"],
                                style: TextStyle(
                                  color: getTypeColor(s["type"]),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              "Date: ${s["date"]}",
                              style: const TextStyle(color: Colors.grey),
                            )
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// STATUS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [

                            Chip(
                              label: Text(
                                "APPROVED",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            )

                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
