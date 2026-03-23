import 'package:flutter/material.dart';
import 'daily_report_screen.dart';
import 'monthly_report_screen.dart';
import 'violation_report_screen.dart';
import '../../services/report_service.dart';
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reports"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Daily"),
              Tab(text: "Monthly"),
              Tab(text: "Violations"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DailyReportScreen(),
            MonthlyReportScreen(),
            ViolationReportScreen(),
          ],
        ),
      ),
    );
  }
}