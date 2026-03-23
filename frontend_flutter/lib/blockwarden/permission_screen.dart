import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {

  List pendingPermissions = [];
  List approvedPermissions = [];
  List rejectedPermissions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {

    try {

      final Map<String, dynamic> data = await PermissionService.getPermissions();

      if (!mounted) return;

      setState(() {
        pendingPermissions = data["pending"] ?? [];
        approvedPermissions = data["approved"] ?? [];
        rejectedPermissions = data["rejected"] ?? [];
        loading = false;
      });

    } catch (e) {

      print(e);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

    }

  }

  Future approve(int id) async {
    await PermissionService.approve(id);
    load();
  }

  Future reject(int id) async {
    await PermissionService.reject(id);
    load();
  }

  Widget buildPermissionList(List permissions, bool allowSwipe) {

    if (permissions.isEmpty) {
      return const Center(child: Text("No records"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: permissions.length,
      itemBuilder: (context, i) {

        final p = permissions[i];

        Widget card = Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    const CircleAvatar(
                      radius: 22,
                      child: Icon(Icons.person),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          p["student_name"] ?? "Student",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "Roll: ${p["student_roll"]}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        Text(
                          "Room: ${p["room"] ?? "-"}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),

                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        p["type"],
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      "Date: ${p["date"]}",
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "Reason: ${p["reason"] ?? "No reason provided"}",
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    if (!allowSwipe)
                      Chip(
                        label: Text(
                          p["status"],
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: p["status"] == "APPROVED"
                            ? Colors.green
                            : Colors.red,
                      )
                  ],
                )

              ],
            ),
          ),
        );

        if (!allowSwipe) return card;

        return Dismissible(
          key: Key(p["id"].toString()),

          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: Colors.green,
            child: const Icon(Icons.check, color: Colors.white),
          ),

          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.close, color: Colors.white),
          ),

          confirmDismiss: (direction) async {

            if (direction == DismissDirection.startToEnd) {
              await approve(p["id"]);
            } else {
              await reject(p["id"]);
            }

            load();
            return true;
          },

          child: card,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(

        appBar: AppBar(
          title: const Text("Permission Requests"),

          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Rejected"),
            ],
          ),
        ),

        body: TabBarView(
          children: [

            buildPermissionList(pendingPermissions, true),

            buildPermissionList(approvedPermissions, false),

            buildPermissionList(rejectedPermissions, false),

          ],
        ),
      ),
    );
  }
}
