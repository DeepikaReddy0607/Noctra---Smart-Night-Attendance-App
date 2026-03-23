import 'package:flutter/material.dart';
import '../../services/report_service.dart'; // IMPORTANT

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String token = "YOUR_TOKEN";

      final result = await ReportService.getDailyReport(token);

      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadReport(String token) async {
    // dummy for now (we already gave full version before)
    print("Downloading...");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return const Center(child: Text("No data"));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              buildCard("Present", data!["present"], Colors.green),
              buildCard("Late", data!["late"], Colors.orange),
            ],
          ),
          Row(
            children: [
              buildCard("Absent", data!["absent"], Colors.red),
              buildCard("Left", data!["left"], Colors.blue),
            ],
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {   // ✅ FIXED async
              String token = "YOUR_TOKEN";
              await downloadReport(token);
            },
            child: const Text("Download Report"),
          )
        ],
      ),
    );
  }

  Widget buildCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title),
              const SizedBox(height: 10),
              Text(
                "$value",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}