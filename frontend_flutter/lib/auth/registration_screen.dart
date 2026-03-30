import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:smart_night_attendance/main.dart';
import 'login_screen.dart';
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController rollController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cotController = TextEditingController();
  String? statusMessage;
bool? isSuccess;
  bool isLoading = false;

  String? selectedBlock;
  String? selectedYear;

  final List<String> blocks = [
    "Bheema",
    "Ghataprabha",
    "Krishnaveni",
    "Munneru",
    "Tungabhadra",
  ];

  final Map<String, String> years = {
    "1st Year": "1",
    "2nd Year": "2",
    "3rd Year": "3",
    "4th Year": "4",
  };

  @override
  void dispose() {
    rollController.dispose();
    emailController.dispose();
    passwordController.dispose();
    roomController.dispose();
    phoneController.dispose();
    cotController.dispose();
    super.dispose();
  }

  
Future<Map<String, dynamic>> _register() async {
  if (rollController.text.isEmpty ||
      emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      roomController.text.isEmpty ||
      phoneController.text.isEmpty ||
      cotController.text.isEmpty ||
      selectedBlock == null ||
      selectedYear == null) {
    return {"ok": false, "msg": "All fields are required"};
  }
  if (!mounted) return {"ok": false, "msg": "Screen disposed"};
  setState(() => isLoading = true);

  try {
    final result = await AuthService.register(
      rollNo: rollController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phone: phoneController.text.trim(),
      block: selectedBlock!,
      roomNumber: roomController.text.trim(),
      cotNumber: cotController.text.trim(),
      year: years[selectedYear!]!,
    ).timeout(const Duration(seconds: 10));

    return {
      "ok": result["status"] == 201,
      "msg": result["status"] == 201
          ? "Registration successful"
          : "Registration failed"
    };
  } on TimeoutException {
    return {"ok": false, "msg": "Server not reachable"};
  } catch (e) {
    return {"ok": false, "msg": "Error: $e"};
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  void _showError(String message) {
    messengerKey.currentState?.clearSnackBars();
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Registration")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: rollController,
                decoration: const InputDecoration(
                  labelText: "Roll Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedYear,
                items: years.keys
                    .map((yearLabel) => DropdownMenuItem(
                          value: yearLabel,
                          child: Text(yearLabel),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedYear = value);
                },
                decoration: const InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedBlock,
                items: blocks
                    .map((block) => DropdownMenuItem(
                          value: block,
                          child: Text(block),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedBlock = value);
                },
                decoration: const InputDecoration(
                  labelText: "Block",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: "Room Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: cotController,
                decoration: const InputDecoration(
                  labelText: "Cot Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading
    ? null
    : () async {
        setState(() {
          statusMessage = null;
        });

        final res = await _register();
        if (!mounted) return;

        setState(() {
          statusMessage = res["msg"];
          isSuccess = res["ok"];
        });

        // ✅ Auto redirect ONLY if success
        if (res["ok"] == true) {
          await Future.delayed(const Duration(seconds: 2));

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }
      },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("REGISTER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}