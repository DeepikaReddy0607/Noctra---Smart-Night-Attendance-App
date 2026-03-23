import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ViolationsScreen extends StatefulWidget {
  final String token;
  const ViolationsScreen({super.key, required this.token});

  @override
  State<ViolationsScreen> createState() => _ViolationsScreenState();
}

class _ViolationsScreenState extends State<ViolationsScreen> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    final res = await ApiService.getViolations(widget.token);
    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Violations")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.verified, color: Colors.green, size: 60),
                      SizedBox(height: 10),
                      Text(
                        "No Violations",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("You're compliant. Keep it up."),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final v = data[i];
                    return ListTile(
                      title: Text(v["student"]),
                      subtitle: Text("Date: ${v["date"]}"),
                      trailing: Text(v["status"]),
                    );
                  },
                ),
    );
  }
}