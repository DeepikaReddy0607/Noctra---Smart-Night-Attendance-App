import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'login_screen.dart';

import '../student/student_dashboard.dart';
import '../caretaker/caretaker_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../blockwarden/blockwarden_dashboard.dart';
import '../cheif_warden/cheif_warden_home.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenService.isLoggedIn(),
      builder: (context, loginSnapshot) {

        // Loading
        if (!loginSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!loginSnapshot.data!) {
          return const LoginScreen();
        }

        // Logged in → fetch token
        return FutureBuilder<String?>(
          future: TokenService.getAccessToken(),
          builder: (context, tokenSnapshot) {

            if (!tokenSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final token = tokenSnapshot.data;

            // Safety check
            if (token == null || token.isEmpty) {
              return const LoginScreen();
            }

            // Fetch role
            return FutureBuilder<String?>(
              future: TokenService.getRole(),
              builder: (context, roleSnapshot) {

                if (!roleSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final role = roleSnapshot.data ?? "";

                // STUDENT
                if (role == "STUDENT") {
                  return const StudentDashboard();
                }

                // CARETAKER
                if (role == "CARETAKER") {
                  return CaretakerDashboard(token: token);
                }

                // BLOCK WARDEN
                if (role == "BLOCK_WARDEN") {
                  return BlockWardenDashboard(token: token!);
                }

                // CHIEF WARDEN / ADMIN
                if (role == "CHIEF_WARDEN") {
                  return  ChiefWardenHome(token: token!);
                }

                // fallback
                return const StudentDashboard();
              },
            );
          },
        );
      },
    );
  }
}