import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends State<AttendanceHistoryScreen> {

  bool isLoading = true;
  List records = [];
  String? error;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final data =
          await AttendanceService.getAttendanceHistory();

      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // ✅ Status color
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "PRESENT":
        return Colors.green.shade100;
      case "LATE":
        return Colors.orange.shade100;
      case "ABSENT":
        return Colors.red.shade100;
      default:
        return Colors.black;
    }
  }

  // ✅ Status icon
  IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case "PRESENT":
        return Icons.check_circle;
      case "LATE":
        return Icons.warning;
      case "ABSENT":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchHistory,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text("Error: $error"))
                : records.isEmpty
                    ? const Center(
                        child: Text("No attendance records"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];

                          final date =
                              record["date"] ?? "";
                          final status =
                              record["status"] ?? "UNKNOWN";
                          final flag =
                              record["flag"] ?? "";

                          return Container(
                            margin:
                                const EdgeInsets.only(bottom: 12),
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  getStatusIcon(status),
                                  size: 30,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        date,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      Text(status),

                                      // 🔥 IMPORTANT: FLAG DISPLAY
                                      if (flag.isNotEmpty)
                                        Text(
                                          "Flag: $flag",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}