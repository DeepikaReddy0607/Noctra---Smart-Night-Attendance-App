import 'dart:async';
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/auth_service.dart';
import 'auth_guard.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String rollNo;

  const OtpVerificationScreen({
    super.key,
    required this.rollNo,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final TextEditingController otpController =
      TextEditingController();

  static const int _otpTimeout = 30;
  int _remainingSeconds = _otpTimeout;
  Timer? _timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = _otpTimeout;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() => _remainingSeconds--);
        }
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      _showError("Enter a valid 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.verifyOtp(
        rollNo: widget.rollNo,
        otp: otpController.text.trim(),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final int status = result["status"];
      final body = result["body"];

      if (status == 200) {
        print("FULL BODY: $body");
        final accessToken = body["access"] ?? body["access_token"];
        final refreshToken = body["refresh_token"] ?? body["refresh_token"];
        final role = body["user"]?["role"];
        print("ACCESS TOKEN SAVED: $accessToken");
        print("REFRESH TOKEN SAVED: $refreshToken");

        if (accessToken == null || refreshToken == null) {
          _showError("Invalid server response");
          return;
        }

        await TokenService.saveTokens(
          accessToken: accessToken.toString(),
          refreshToken: refreshToken.toString(),
          role: role?.toString() ?? "STUDENT",
        );
        print("SAVED ACCESS: $accessToken");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGuard()),
          (route) => false,
        );

        return;
      }

      String message = "Invalid or expired OTP";

      if (body is Map && body.isNotEmpty) {
        message = body.values.first.toString();
      }

      _showError(message);

    } on TimeoutException {
      _showError("Server not reachable");
    } catch (e) {
      _showError("OTP verification failed");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("OTP Verification"),
      automaticallyImplyLeading: false,
    ),

    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 40),

            Image.asset(
              "assets/images/noctra_logo.png",
              height: 70,
            ),

            const SizedBox(height: 30),

            const Text(
              "Enter Verification Code",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "OTP sent to ${widget.rollNo}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 35),

            /// OTP input
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              onChanged: (value) {
                if (value.length == 6) {
                  _verifyOtp();
                }
              },
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "------",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// timer
            if (_remainingSeconds > 0)
              Text(
                "Resend OTP in $_remainingSeconds s",
                style: const TextStyle(color: Colors.grey),
              )
            else
              TextButton(
                onPressed: () {
                  _startTimer();
                  AuthService.resendOtp(widget.rollNo);
                },
                child: const Text("Resend OTP"),
              ),

            const SizedBox(height: 40),

            /// verify button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("VERIFY & LOGIN"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
}