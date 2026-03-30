import 'package:flutter/material.dart';
import 'cheif_warden_dashboard.dart';
import 'violations_screen.dart';
import 'assign_caretaker_screen.dart';
import 'risk_screen.dart';
import 'student_approval_screen.dart';

class ChiefWardenHome extends StatefulWidget {
  final String token;
  const ChiefWardenHome({super.key, required this.token});

  @override
  State<ChiefWardenHome> createState() => _ChiefWardenHomeState();
}

class _ChiefWardenHomeState extends State<ChiefWardenHome> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ChiefWardenDashboard(token: widget.token), // your screen
      ViolationsScreen(token: widget.token),
      CaretakerAssignmentScreen(token: widget.token),
      StudentApprovalScreen(token: widget.token),
      RiskScreen(token: widget.token),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Violations"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Duties"),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: "Approve"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "Risk"),
        ],
      ),
    );
  }
}