import 'package:flutter/material.dart';

import '../services/blockwarden_service.dart';
import '../services/token_service.dart';
import '../auth/auth_guard.dart';

import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';

import '../screens/attendance_monitor.dart';
import 'permission_screen.dart';
import '../caretaker/violations_screen.dart';
import '../screens/reports/reports_screen.dart';
class BlockWardenDashboard extends StatefulWidget {
  final String token;
  const BlockWardenDashboard({super.key, required this.token});

  @override
  State<BlockWardenDashboard> createState() => _BlockWardenDashboardState();
}

class _BlockWardenDashboardState extends State<BlockWardenDashboard> {

  bool loading = true;
  String? errorMessage;
  
  int totalStudents = 0;
  int present = 0;
  int late = 0;
  int absent = 0;
  int violations = 0;

  String block = "";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {

      final data = await BlockWardenService.getDashboard();

      setState(() {

        block = data["block"] ?? "";

        totalStudents = data["total_students"] ?? 0;
        present = data["present"] ?? 0;
        late = data["late"] ?? 0;
        absent = data["absent"] ?? 0;
        violations = data["violations"] ?? 0;

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
        errorMessage = "Failed to load dashboard";
      });
    }
  }

  Future<void> logout() async {

    await TokenService.clearAll();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGuard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    double progress = totalStudents == 0 ? 0 : present / totalStudents;

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      appBar: AppBar(
        title: Text("Block $block Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: loadDashboard,
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: logout,
          ),
        ],
      ),

      body: RefreshIndicator(

        onRefresh: loadDashboard,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Attendance Progress

              Center(
                child: GlassCard(
                  child: Column(
                    children: [

                      const Text(
                        "Night Attendance Progress",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 170,
                        width: 170,

                        child: Stack(
                          alignment: Alignment.center,

                          children: [

                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.white10,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.green),
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text(
                                  "${(progress * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text(
                                  "Attendance",
                                  style: TextStyle(
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Stats Cards

              Row(
                children: [

                  Expanded(
                    child: StatCard(
                      title: "Students",
                      value: "$totalStudents",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: StatCard(
                      title: "Present",
                      value: "$present",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: StatCard(
                      title: "Late",
                      value: "$late",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: StatCard(
                      title: "Violations",
                      value: "$violations",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Quick Actions

              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.3,

                children: [

                  ActionCard(
                    title: "View Attendance",
                    icon: Icons.fact_check,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceMonitorScreen(),
                        ),
                      );
                    },
                  ),

                  ActionCard(
                    title: "Outing Permissions",
                    icon: Icons.assignment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PermissionScreen(),
                        ),
                      );
                    },
                  ),

                  ActionCard(
                    title: "Violations",
                    icon: Icons.warning,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ViolationsScreen(token: widget.token),),
                      );
                    },
                  ),

                  ActionCard(
                    title: "Reports",
                    icon: Icons.analytics,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Footer Info

              Center(
                child: Text(
                  "NOCTRA Hostel Monitoring System",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}