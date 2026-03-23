import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../widgets/glass_card.dart';

class AttendanceMonitorScreen extends StatefulWidget {
  const AttendanceMonitorScreen({super.key});

  @override
  State<AttendanceMonitorScreen> createState() =>
      _AttendanceMonitorScreenState();
}

class _AttendanceMonitorScreenState
    extends State<AttendanceMonitorScreen> {

  bool loading = true;
  String? error;

  List lateStudents = [];
  List absentStudents = [];
  List libraryStudents = [];

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {

    setState(() {
      loading = true;
      error = null;
    });

    try {

      final data = await AttendanceService.getBlockAttendance();

      setState(() {
        lateStudents = data["late_students"] ?? [];
        absentStudents = data["absent_students"] ?? [];
        libraryStudents = data["library_students"] ?? [];
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
        error = "Failed to load attendance";
      });
    }
  }

  Widget buildList(String title, List students) {

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          if (students.isEmpty)
            const Text(
              "None",
              style: TextStyle(color: Colors.white60),
            ),

          ...students.map((s) {
            return ListTile(
              title: Text(
                s["student__roll_no"] ?? s["roll_no"],
                style: const TextStyle(color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      appBar: AppBar(
        title: const Text("Attendance Monitor"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: RefreshIndicator(

        onRefresh: loadAttendance,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              buildList("Late Students", lateStudents),

              const SizedBox(height: 20),

              buildList("Absent Students", absentStudents),

              const SizedBox(height: 20),

              buildList("Library Students", libraryStudents),
            ],
          ),
        ),
      ),
    );
  }
}