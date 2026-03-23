import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/caretaker_dashboard_provider.dart';
import '../models/caretaker_dashboard_model.dart';
import '../services/token_service.dart';
import '../auth/login_screen.dart';
import '../widgets/animated_counter.dart';
import '../widgets/glass_stat_card.dart';
import '../screens/attendance_monitor.dart';
import 'approved_students_screen.dart';
import 'library_monitor_screen.dart';
import 'violations_screen.dart';
import 'emergency_screen.dart';
import 'dart:async';
class CaretakerDashboard extends StatefulWidget {
  final String token;
  CaretakerDashboard({super.key, required this.token});

  @override
  State<CaretakerDashboard> createState() => _CaretakerDashboardState();
}

class _CaretakerDashboardState extends State<CaretakerDashboard>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

 @override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

  _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  Future.microtask(() {
    Provider.of<CaretakerDashboardProvider>(context, listen: false)
        .loadDashboard();
    _controller.forward();
  });
}

  Future<void> _refresh() async {
    await Provider.of<CaretakerDashboardProvider>(context, listen: false)
        .loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaretakerDashboardProvider>(context);
    final CaretakerDashboardModel? data = provider.dashboard;

    if (provider.loading || data == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF071024),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF071024),

      appBar: AppBar(
        backgroundColor: const Color(0xFF071024),
        elevation: 0,
        title: const Text(
          "NOCTRA",
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const Icon(Icons.notifications_none),
          const SizedBox(width: 15),
          const Icon(Icons.person_outline),
          const SizedBox(width: 15),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await TokenService.clearAll();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,

        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                 _blockHeader(data),

                  const SizedBox(height: 20),

                  _statsGrid(data),

                  const SizedBox(height: 20),

                  _safetyMeter(data.present, data.totalStudents),

                  const SizedBox(height: 20),

                  _blockStatus(data),

                  const SizedBox(height: 20),

                  _sectionTitle("Quick Actions"),

                  const SizedBox(height: 10),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,

                    children: [

                      _actionButton(
                        "Attendance Monitor",
                        Icons.fact_check,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AttendanceMonitorScreen(),
                            ),
                          );
                        },
                      ),

                      _actionButton(
                        "Library Monitor",
                        Icons.local_library,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LibraryMonitorScreen(token: widget.token),
                            ),
                          );

                        },
                      ),

                      _actionButton(
                        "Violations",
                        Icons.warning,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViolationsScreen(token: widget.token),
                            ),
                          );
                        },
                      ),

                      _actionButton(
                        "Emergency",
                        Icons.report_problem,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EmergencyScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle),
                      title: const Text("Approved Students"),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ApprovedStudentsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [

                        const Icon(Icons.info_outline, color: Colors.orange),

                        const SizedBox(width: 10),

                        Text(
                          "${data.late} late • ${data.absent} absent • ${data.libraryStudents.length} in library",
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (data.absent > 0 || data.late > 3) _alertPanel(data),

                  const SizedBox(height: 20),

                  _sectionTitle("Late Students"),
                  _studentList(data.lateStudents, Colors.orange),

                  const SizedBox(height: 20),

                  _sectionTitle("Absent Students"),
                  _studentList(data.absentStudents, Colors.red),

                  const SizedBox(height: 20),

                  _sectionTitle("Library Students"),
                  _studentList(data.libraryStudents, Colors.blue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

   Widget _blockHeader(CaretakerDashboardModel data) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A)
          ]
        ),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.security, color: Colors.white),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                data.block,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "Monitoring • ${data.shift}",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const Spacer(),

          _statusChip(
            data.absent > 3 ? "CRITICAL" : "STABLE",
            data.absent > 3 ? Colors.red : Colors.green,
          )
        ],
      ),
    );
  }

  Widget _blockStatus(CaretakerDashboardModel data) {
    String status = "STABLE";
    Color color = Colors.green;

    if (data.absent > 3) {
      status = "CRITICAL";
      color = Colors.red;
    } else if (data.late > 5) {
      status = "WARNING";
      color = Colors.orange;
    }
    else if (data.present > data.totalStudents * 0.9){
      status = "STABLE";
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B3D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color),
          const SizedBox(width: 10),
          Text(
            "Block Status: $status",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _statsGrid(CaretakerDashboardModel data) {
    return Row(
      children: [

        Expanded(
          child: GlassStatCard(
            title: "Students",
            value: data.totalStudents,
            color: Colors.blue,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: GlassStatCard(
            title: "Present",
            value: data.present,
            color: Colors.green,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: GlassStatCard(
            title: "Late",
            value: data.late,
            color: Colors.orange,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: GlassStatCard(
            title: "Absent",
            value: data.absent,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, int value, Color color) {

  return Container(
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: const Color(0xFF0F1B3D),
      borderRadius: BorderRadius.circular(20),

      boxShadow: [

        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 25,
          spreadRadius: 1,
        )
      ],
    ),

    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        AnimatedCounter(
          value: value,
          color: color,
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        )
      ],
    ),
  );
}

  Widget _alertPanel(CaretakerDashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${data.absent} students absent without permission",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _studentList(List<dynamic> students, Color color) {

    if (students.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "None",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Column(
      children: students.map((student) {

        String roll =
            student["student__roll_no"] ??
            student["roll_no"] ??
            "Unknown";

        return _studentTile(roll, color);

      }).toList(),
    );
  }
  Widget _safetyMeter(int present, int total) {

  double percent = total == 0 ? 0 : present / total;

  return Container(
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: const Color(0xFF0F1B3D),
      borderRadius: BorderRadius.circular(16),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Hostel Safety Level",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: percent),
          duration: const Duration(seconds: 1),

          builder: (context, value, child) {

            return LinearProgressIndicator(
              value: value,
              minHeight: 10,
              color: Colors.green,
              backgroundColor: Colors.white12,
            );
          },
        ),

        const SizedBox(height: 8),

        Text(
          "${(percent * 100).toStringAsFixed(0)}% students inside hostel",
          style: const TextStyle(color: Colors.white70),
        )
      ],
    ),
  );
}
  Widget _studentTile(String roll, Color color) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),

      decoration: BoxDecoration(
        color: const Color(0xFF0F1B3D),
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.person, color: Colors.white),
        ),

        title: Text(
          roll,
          style: const TextStyle(color: Colors.white),
        ),

        subtitle: const Text(
          "Attendance anomaly detected",
          style: TextStyle(color: Colors.white60),
        ),
      ),
    );
  }
  Widget _statusChip(String status, Color color) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: const Color(0xFF0F1B3D),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, color: Colors.white, size: 28),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}