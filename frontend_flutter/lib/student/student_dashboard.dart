import 'package:flutter/material.dart';
import '../services/student_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';

import 'apply_permission_screen.dart';
import 'mark_attendance_screen.dart';
import 'attendance_history_screen.dart';
import '../widgets/attendance_chart.dart';

import '../services/token_service.dart';
import '../auth/login_screen.dart';
import 'my_permissions_screen.dart';

import 'help_screen.dart';
import 'package:smart_night_attendance/main.dart';
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  String rollNo = "";
  String block = "";
  String status = "NOT_MARKED";

  String attendancePercent = "0%";
  int violations = 0;
  int permissions = 0;
  List<int> weeklyAttendance = [1, 1, 1, 0, 1, 1, 0];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

    final result = await StudentService.getDashboard();

    if (!mounted) return;

    if (result["status"] == 200) {

      final data = result["body"];

      setState(() {

        rollNo = data["roll_no"] ?? "";
        block = data["block"] ?? "";
        status = data["attendance_status"] ?? "NOT_MARKED";

        attendancePercent = "${data["attendance_percent"] ?? 0}%";
        violations = data["violations"] ?? 0;
        permissions = data["permissions"] ?? 0;

        loading = false;
      });

    } else {

      setState(() {
        loading = false;
      });
    }
  }

  Color statusColor() {
    switch (status) {
      case "PRESENT":
        return Colors.green;
      case "LATE":
        return Colors.orange;
      case "ABSENT":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

  appBar: AppBar(
    backgroundColor: const Color(0xFF020617),
    elevation: 0,
    title: const Text(
      "NOCTRA",
      style: TextStyle(
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [

      IconButton(
        icon: const Icon(Icons.notifications_none),
        onPressed: () {},
      ),

      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {

          await TokenService.clearAll();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
      ),

      const SizedBox(width: 10),
    ], 
  ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(

          child: RefreshIndicator(
            onRefresh: loadDashboard,

            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                /// PROFILE CARD
                  GlassCard(
                    child: Row(
                      children: [

                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.person, color: Colors.white),
                        ),

                        const SizedBox(width: 15),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Roll No: $rollNo",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Hostel Block $block",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// STATS
                  Row(
                    children: [

                      Expanded(
                        child: StatCard(
                          title: "Attendance",
                          value: attendancePercent,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: StatCard(
                          title: "Violations",
                          value: violations.toString(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: StatCard(
                          title: "Permissions",
                          value: permissions.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  AttendanceChart(
                    weeklyData: weeklyAttendance,
                  ),
                  const SizedBox(height: 30),

                  const SizedBox(height: 25),

                  /// ATTENDANCE ALERT
                  if(status == "NOT_MARKED")
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 15),

                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Row(
                        children: const [

                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange),

                          SizedBox(width: 10),

                          Text(
                            "Attendance not marked yet",
                            style: TextStyle(color: Colors.orange),
                          )
                        ],
                      ),
                    ),

                  /// ATTENDANCE STATUS
                  GlassCard(
                    child: Row(
                      children: [

                        StatusIndicator(color: statusColor()),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Today's Attendance",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),

                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor(),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// PRIMARY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint),

                      label: const Text(
                        "MARK NIGHT ATTENDANCE",
                        style: TextStyle(
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        shadowColor: Colors.deepPurpleAccent,
                        backgroundColor: const Color(0xFF5B7CFF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () async {

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MarkAttendanceScreen(),
                          ),
                        );

                        loadDashboard();
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text(
                        "EMERGENCY ALERT",
                        style: TextStyle(
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 8,
                        shadowColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {

                        final messenger = ScaffoldMessenger.of(context);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Confirm Emergency"),
                            content: const Text(
                              "Are you sure you want to send an emergency alert?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("YES"),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        try {
                          await StudentService.sendEmergency();

                          if (!mounted) return;

                          messengerKey.currentState?.showSnackBar(
                            const SnackBar(content: Text("Emergency alert sent")),
                          );

                        } catch (e) {

                          if (!mounted) return;

                          messenger.showSnackBar(
                            const SnackBar(content: Text("Failed to send emergency")),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,

                    children: [

                      ActionCard(
                        icon: Icons.history,
                        title: "Attendance History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),

                      ActionCard(
                        icon: Icons.assignment,
                        title: "Apply Permission",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ApplyPermissionScreen(),
                            ),
                          );
                        },
                      ),

                      ActionCard(
                        icon: Icons.event,
                        title: "My Permissions",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyPermissionsScreen(),
                            ),
                          );
                        },
                      ),

                      ActionCard(
                        icon: Icons.help_outline,
                        title: "Help",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HelpScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}