import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/caretaker_dashboard_model.dart';

class CaretakerDashboardProvider extends ChangeNotifier {

  CaretakerDashboardModel? dashboard;
  bool loading = true;
  String? error;

  Future<void> loadDashboard() async {

    loading = true;
    notifyListeners();

    try {

      final result = await AuthService.getCaretakerDashboard();

      if (result["status"] == 200) {

        dashboard = CaretakerDashboardModel.fromJson(result["body"]);
        error = null;

      } else {

        error = result["body"]["error"] ?? "Unknown error";
      }

    } catch (e) {

      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}