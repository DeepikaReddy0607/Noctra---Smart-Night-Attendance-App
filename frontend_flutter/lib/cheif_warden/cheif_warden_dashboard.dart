import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../services/token_service.dart';
import '../auth/login_screen.dart';

class ChiefWardenDashboard extends StatefulWidget {
  final String token;
  const ChiefWardenDashboard({super.key, required this.token});

  @override
  State<ChiefWardenDashboard> createState() => _ChiefWardenDashboardState();
}

class _ChiefWardenDashboardState extends State<ChiefWardenDashboard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? dashboardData;
  List<dynamic> blockStats = [];
  bool isLoading = true;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final headers = {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      };

      final res1 = await http.get(
        Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/dashboard/"),
        headers: headers,
      );

      final res2 = await http.get(
        Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/block-stats/"),
        headers: headers,
      );

      setState(() {
        dashboardData = jsonDecode(res1.body);
        blockStats = jsonDecode(res2.body);
        isLoading = false;
      });

      controller.forward();

    } catch (e) {
      print("ERROR: $e");
    }
  }
  void logout() async {
  final confirm = await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Logout"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await TokenService.clearAll();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
  // 🔥 KPI CARD WITH ANIMATION
  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(
                "$value",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 PIE CHART
  Widget buildPieChart() {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        sections: [
          PieChartSectionData(
            value: dashboardData!["present"].toDouble(),
            color: Colors.green,
            title: "P",
            radius: 60,
          ),
          PieChartSectionData(
            value: dashboardData!["late"].toDouble(),
            color: Colors.orange,
            title: "L",
            radius: 60,
          ),
          PieChartSectionData(
            value: dashboardData!["absent"].toDouble(),
            color: Colors.red,
            title: "A",
            radius: 60,
          ),
        ],
      ),
    );
  }

  // 🔥 LINE CHART (TREND)
  Widget buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: [
              FlSpot(0, 60),
              FlSpot(1, 70),
              FlSpot(2, 65),
              FlSpot(3, 80),
              FlSpot(4, 75),
            ],
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  bool isProblemBlock(dynamic block) {
    return block["late"] > 5 || block["absent"] > 3;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: false,
      appBar: AppBar(title: const Text("Chief Warden Dashboard"),actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: logout,
    ),
  ],),
      body: SafeArea(
        top: true,
        bottom: false,
        child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: isLoading ? 0 : 1,
        child: RefreshIndicator(
          onRefresh: fetchDashboard,
          child: ListView(
  physics: const BouncingScrollPhysics(),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  children: [

    /// KPI
    Row(
      children: [
        statCard("Students", dashboardData!["total_students"], Icons.people, Colors.blue),
        statCard("Present", dashboardData!["present"], Icons.check, Colors.green),
      ],
    ),
    Row(
      children: [
        statCard("Late", dashboardData!["late"], Icons.access_time, Colors.orange),
        statCard("Absent", dashboardData!["absent"], Icons.cancel, Colors.red),
      ],
    ),

    const SizedBox(height: 20),

    /// PIE
    const Text("Attendance Distribution",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    SizedBox(height: 220, child: buildPieChart()),

    const SizedBox(height: 20),

    /// LINE
    const Text("Trend Analysis",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    SizedBox(height: 200, child: buildLineChart()),

    const SizedBox(height: 20),

    /// BLOCKS
    const Text("Block Overview",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),

    ...blockStats.map((block) {
      final isProblem = isProblemBlock(block);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isProblem ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isProblem ? Colors.red : Colors.grey.shade300),
        ),
        child: ListTile(
          leading: Icon(Icons.apartment,
              color: isProblem ? Colors.red : Colors.blue),
          title: Text(block["block"]),
          subtitle: Text(
              "P:${block["present"]}  L:${block["late"]}  A:${block["absent"]}"),
          trailing: isProblem
              ? const Icon(Icons.warning, color: Colors.red)
              : null,
        ),
      );
    }).toList(),

    /// 🔥 FINAL FIX (IMPORTANT)
    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
  ],
),
        ),),
      ),
    );
  }
}