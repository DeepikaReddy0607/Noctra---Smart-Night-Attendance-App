import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String token = "YOUR_TOKEN";
      final result = await ReportService.getMonthlyReport(token);

      if(!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final s = data[index];

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(s["roll_no"].toString()),
            subtitle: Text("P:${s["present"]} L:${s["late"]} A:${s["absent"]}"),
            trailing: Text("${s["percentage"]}%"),
          ),
        );
      },
    );
  }
}