import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/token_service.dart';
import '../main.dart';
import 'dart:async';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {

  List data = [];
  bool loading = true;

  Timer? _timer;

@override
void initState() {
  super.initState();
  fetchAlerts();

  _timer = Timer.periodic(const Duration(seconds: 5), (_) {
    fetchAlerts();
  });
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}

  Future<void> fetchAlerts() async {
    print("FETCH START");
    final token = await TokenService.getAccessToken();
    print("TOKEN: $token");

    final res = await http.get(
      Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/hostel/emergency/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    print("STATUS CODE: ${res.statusCode}");
    print("BODY: ${res.body}");
    final body = jsonDecode(res.body);

    setState(() {
      data = body;
      loading = false;
    });
  }

  Future<void> resolveAlert(int id) async {
    final token = await TokenService.getAccessToken();

    await http.patch(
      Uri.parse("https://uniniquitous-overfranchised-ileana.ngrok-free.dev/api/hostel/emergency/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"id": id}),
    );

    messengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text("Resolved")),
    );

    fetchAlerts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Alerts")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("No active emergencies"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {

                    final e = data[i];

                    return Card(
                      color: Colors.red.shade900,
                      margin: const EdgeInsets.all(10),

                      child: ListTile(
                        leading: const Icon(Icons.warning, color: Colors.white),

                        title: Text(
                          e["student"],
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          "${e["message"]}\n${e["time"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () => resolveAlert(e["id"]),
                          child: const Text("Resolve"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}