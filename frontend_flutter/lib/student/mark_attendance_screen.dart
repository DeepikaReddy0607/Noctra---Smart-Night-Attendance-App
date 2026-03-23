import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState
    extends State<MarkAttendanceScreen> {
      
  bool isSubmitting = false;
  String? message;

  // 🔹 Get Current GPS Location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // 🔹 Main Attendance Logic
  Future<void> _markAttendance() async {
    print("MARK ATTENDANCE BUTTON PRESSED");
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
      message = null;
    });

    final LocalAuthentication auth = LocalAuthentication();
    bool biometricSuccess = false;

    try {
      biometricSuccess = await auth.authenticate(
        localizedReason:
            'Authenticate to mark attendance',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (_) {
      biometricSuccess = false;
    }

    if (!biometricSuccess) {
      setState(() {
        isSubmitting = false;
        message = "Biometric authentication failed";
      });
      return;
    }

    try {
      final position = await _getCurrentLocation();

      final result =
          await AuthService.markAttendance(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (result["status"] == 200) {
        final backendStatus =
            result["body"]["status"];

        setState(() {
          message =
              "Attendance marked: $backendStatus";
        });
      } else {
        setState(() {
          message = result["body"]?["error"] ??
              "Attendance failed";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
      });
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Mark Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            const Icon(Icons.fingerprint,
                size: 80),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : _markAttendance,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Mark Attendance",
                        style: TextStyle(
                            fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}