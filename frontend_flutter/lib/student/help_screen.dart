import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget contentText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sectionTitle("How to Use"),
          contentText(
              "• Open the app before attendance time\n"
              "• Stay inside your hostel block\n"
              "• Tap 'Mark Attendance'\n"
              "• Complete biometric verification\n"
              "• Wait for confirmation"),

          sectionTitle("Attendance Rules"),
          contentText(
              "• Attendance is allowed only during fixed time\n"
              "• Late attendance will be marked as 'Late'\n"
              "• Leaving after marking → 'Left Block'\n"
              "• Not marking → 'Absent'"),

          sectionTitle("FAQs"),
          contentText(
              "Q: Why can’t I mark attendance?\n"
              "A: You may be outside hostel or time window not started.\n\n"
              "Q: Why is my attendance marked Late?\n"
              "A: You marked after cutoff time.\n\n"
              "Q: Why am I marked Absent?\n"
              "A: You didn’t mark attendance within time.\n\n"
              "Q: How to apply permission?\n"
              "A: Use the Permission section in app."),

          sectionTitle("Contact"),
          contentText(
              "Warden: +91 9876543210\n"
              "Email: support@hostel.com"),
        ],
      ),
    );
  }
}