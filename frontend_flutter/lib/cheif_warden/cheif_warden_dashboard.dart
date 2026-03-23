import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class ChiefWardenDashboard extends StatefulWidget {
  const ChiefWardenDashboard({super.key});

  @override
  State<ChiefWardenDashboard> createState() => _ChiefWardenDashboardState();
}

class _ChiefWardenDashboardState extends State<ChiefWardenDashboard> {
  Map<String, dynamic>? dashboardData;
  List<dynamic> blockStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    final res1 = await http.get(Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/dashboard/"));
    final res2 = await http.get(Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/chief-warden/block-stats/"));

    setState(() {
      dashboardData = jsonDecode(res1.body);
      blockStats = jsonDecode(res2.body);
      isLoading = false;
    });
  }

  Widget statCard(String title, int value, IconData icon, List<Color> gradient) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
              value: dashboardData!["present"].toDouble(),
              title: "Present",
              radius: 50),
          PieChartSectionData(
              value: dashboardData!["late"].toDouble(),
              title: "Late",
              radius: 50),
          PieChartSectionData(
              value: dashboardData!["absent"].toDouble(),
              title: "Absent",
              radius: 50),
        ],
      ),
    );
  }

  Widget insightBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "⚡ Insight: Late attendance increased today. Monitor Block A closely.",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chief Warden Dashboard")),
      body: RefreshIndicator(
        onRefresh: fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// 🔥 STAT CARDS
              Row(
                children: [
                  statCard("Students", dashboardData!["total_students"],
                      Icons.people, [Colors.blue, Colors.blueAccent]),
                  statCard("Present", dashboardData!["present"],
                      Icons.check, [Colors.green, Colors.teal]),
                ],
              ),
              Row(
                children: [
                  statCard("Late", dashboardData!["late"],
                      Icons.access_time, [Colors.orange, Colors.deepOrange]),
                  statCard("Absent", dashboardData!["absent"],
                      Icons.cancel, [Colors.red, Colors.redAccent]),
                ],
              ),

              const SizedBox(height: 20),

              /// 📊 PIE CHART
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Attendance Distribution",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 10),

              SizedBox(height: 200, child: buildPieChart()),

              const SizedBox(height: 20),

              /// ⚡ INSIGHT BOX
              insightBox(),

              const SizedBox(height: 20),

              /// 🏢 BLOCK LIST
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Block Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blockStats.length,
                itemBuilder: (context, index) {
                  final block = blockStats[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.apartment),
                      title: Text(block["block"]),
                      subtitle: Text(
                          "P: ${block["present"]}  L: ${block["late"]}  A: ${block["absent"]}"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}