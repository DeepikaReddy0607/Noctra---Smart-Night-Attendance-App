import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  final String token;
  const AnalyticsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: const Center(
        child: Text("📊 Add Chart Here (Pie / Line)"),
      ),
    );
  }
}