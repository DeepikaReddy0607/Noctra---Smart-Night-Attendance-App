import 'package:flutter/material.dart';
import '../services/student_permission_service.dart';

enum PermissionType { library, nonLocal }

class ApplyPermissionScreen extends StatefulWidget {
  const ApplyPermissionScreen({super.key});

  @override
  State<ApplyPermissionScreen> createState() =>
      _ApplyPermissionScreenState();
}

class _ApplyPermissionScreenState extends State<ApplyPermissionScreen> {
  PermissionType? selectedPermission;
  bool isLoading = false;

  DateTime? fromDate;
  DateTime? toDate;

  final int minAdvanceDays = 2;

  DateTime dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  Future<void> pickDate({required bool isFrom}) async {
    if (!isFrom && fromDate == null) return;

    final today = dateOnly(DateTime.now());
    final firstDate =
        isFrom ? today.add(Duration(days: minAdvanceDays)) : fromDate!;

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        fromDate = dateOnly(picked);
        toDate = null;
      } else {
        toDate = dateOnly(picked);
      }
    });
  }

  bool isValidNonLocal() =>
      fromDate != null && toDate != null && !toDate!.isBefore(fromDate!);

 Future<void> submitPermission() async {
  if (selectedPermission == null) return;

  if (selectedPermission == PermissionType.nonLocal &&
      !isValidNonLocal()) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Select valid From & To dates")),
    );
    return;
  }

  setState(() => isLoading = true);
  
  try {
    final today = DateTime.now();
    final typeToSend = selectedPermission == PermissionType.library
      ? "LIBRARY"
      : "OUTING";
    print("TYPE SENT: $typeToSend");
    await StudentPermissionService.applyPermission(
      type: typeToSend,
      
      date: fromDate != null
          ? "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}"
          : "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}",
    );

    if (!mounted) return;

    Navigator.pop(context, true);

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );

  } finally {
    if (!mounted) return;
    setState(() => isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply Permission")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Permission Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            RadioListTile<PermissionType>(
              title: const Text("Library Permission (till 12:00 AM)"),
              value: PermissionType.library,
              groupValue: selectedPermission,
              onChanged: isLoading
                  ? null
                  : (val) => setState(() {
                        selectedPermission = val;
                        fromDate = null;
                        toDate = null;
                      }),
            ),

            RadioListTile<PermissionType>(
              title: const Text("Non-Local Outing Permission"),
              value: PermissionType.nonLocal,
              groupValue: selectedPermission,
              onChanged: isLoading
                  ? null
                  : (val) => setState(() {
                        selectedPermission = val;
                        fromDate = null;
                        toDate = null;
                      }),
            ),

            if (selectedPermission == PermissionType.nonLocal) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => pickDate(isFrom: true),
                      child: Text(fromDate == null
                          ? "From Date"
                          : "${fromDate!.day}-${fromDate!.month}-${fromDate!.year}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading || fromDate == null
                          ? null
                          : () => pickDate(isFrom: false),
                      child: Text(toDate == null
                          ? "To Date"
                          : "${toDate!.day}-${toDate!.month}-${toDate!.year}"),
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitPermission,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Request",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}