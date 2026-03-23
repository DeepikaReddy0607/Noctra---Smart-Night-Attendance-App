import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class ViolationReportScreen extends StatefulWidget {
  const ViolationReportScreen({super.key});

  @override
  State<ViolationReportScreen> createState() => _ViolationReportScreenState();
}

class _ViolationReportScreenState extends State<ViolationReportScreen> {
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
      final result = await ReportService.getViolations(token);

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
        final v = data[index];

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(v["student"].toString()),
            subtitle: Text("${v["type"]} - ${v["date"]}"),
          ),
        );
      },
    );
  }
}