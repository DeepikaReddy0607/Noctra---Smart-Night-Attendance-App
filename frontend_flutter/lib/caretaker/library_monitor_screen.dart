import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LibraryMonitorScreen extends StatefulWidget {
  final String token;
  const LibraryMonitorScreen({super.key, required this.token});

  @override
  State<LibraryMonitorScreen> createState() =>
      _LibraryMonitorScreenState();
}

class _LibraryMonitorScreenState extends State<LibraryMonitorScreen> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    final res = await ApiService.getLibraryStudents(widget.token);
    print("LIBRARY RESPONSE: $res");
    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library Monitor")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final s = data[i];
                return ListTile(
                  title: Text(s["student"]),
                  subtitle: Text("Status: ${s["status"]}"),
                );
              },
            ),
    );
  }
}