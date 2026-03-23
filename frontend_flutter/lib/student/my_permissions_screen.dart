import 'package:flutter/material.dart';
import '../services/student_permission_service.dart';

class MyPermissionsScreen extends StatefulWidget {
  const MyPermissionsScreen({super.key});

  @override
  State<MyPermissionsScreen> createState() => _MyPermissionsScreenState();
}

class _MyPermissionsScreenState extends State<MyPermissionsScreen> {
  List permissions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    try {
      final data = await StudentPermissionService.getMyPermissions();
      setState(() {
        permissions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // ✅ Status color
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ✅ Icon mapping
  IconData getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'OUTING':
        return Icons.directions_walk;
      default:
        return Icons.info;
    }
  }

  // ✅ Display mapping
  String displayType(String type) {
    switch (type.toUpperCase()) {
      case "OUTING":
        return "Non-Local Outing";
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Permissions"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchPermissions,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text("Error: $error"))
                : permissions.isEmpty
                    ? const Center(
                        child: Text(
                          "No permission requests yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: permissions.length,
                        itemBuilder: (context, index) {
                          final item = permissions[index];

                          final type = item['permission_type'] ?? 'UNKNOWN';
                          final status = item['status'] ?? 'PENDING';
                          final date = item['date'] ?? '';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                getTypeIcon(type),
                                size: 30,
                                color: Colors.blue,
                              ),
                              title: Text(
                                displayType(type),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Date: $date"),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}