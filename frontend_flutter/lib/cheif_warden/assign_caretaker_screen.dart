import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CaretakerAssignmentScreen extends StatefulWidget {
  final String token;
  const CaretakerAssignmentScreen({super.key, required this.token
  });

  @override
  State<CaretakerAssignmentScreen> createState() =>
      _CaretakerAssignmentScreenState();
}

class _CaretakerAssignmentScreenState
    extends State<CaretakerAssignmentScreen> {
  List<dynamic> duties = [];
  List<dynamic> caretakers = [];

  bool isLoading = false;

  String? selectedBlock;
  String? selectedShift;
  String? selectedCaretakerId;

  final TextEditingController dateController = TextEditingController();

  int? editingDutyId;

  final Map<String, int> blocks = {
  "Bheema": 1,
  "Ghataprabha": 2,
  "Krishnaveni": 3,
  "Munneru": 4,
  "Tungabhadra": 5,
};

  final Map<String, String> shifts = {
    "Morning": "MORNING",
    "Evening": "EVENING",
    "Night": "NIGHT",
  };

  @override
  void initState() {
    super.initState();
    fetchDuties();
    fetchCaretakers();
  }
  @override
void dispose() {
  dateController.dispose(); // or tabController.dispose()
  super.dispose();
}
  // ================= FETCH DUTIES =================
  Future<void> fetchDuties() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final res = await AuthService.get("chief-warden/caretaker/list/", widget.token,);
      if (!mounted) return
      setState(() {
        duties = res;
      });
    } catch (e) {
      debugPrint("Fetch duties error: $e");
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // ================= FETCH CARETAKERS =================
  Future<void> fetchCaretakers() async {
    try {
      final res = await AuthService.get("chief-warden/caretaker/caretakers/", widget.token,);
      if (!mounted) return;
      setState(() {
        caretakers = res;
      });
    } catch (e) {
      debugPrint("Fetch caretakers error: $e");
    }
  }

  // ================= ASSIGN =================
  Future<void> assignDuty() async {
  print("ASSIGN CLICKED");

  print("caretaker: $selectedCaretakerId");
  print("block: $selectedBlock");
  print("shift: $selectedShift");
  print("date: ${dateController.text}");

  if (selectedCaretakerId == null ||
      selectedBlock == null ||
      selectedShift == null ||
      dateController.text.isEmpty) {
    print("VALIDATION FAILED ❌");
    return;
  }

  final payload = {
    "caretaker": selectedCaretakerId,
    "block": blocks[selectedBlock],
    "shift": shifts[selectedShift],
    "duty_date": dateController.text,
  };

  print("SENDING: $payload");

  setState(() => isLoading = true);

  try {
    await AuthService.post(
      "chief-warden/caretaker/assign/",
      payload,
      widget.token,
    );

    print("SUCCESS ✅");

    await fetchDuties();
    clearForm();
  } catch (e) {
    print("ERROR ❌: $e");
  }

  setState(() => isLoading = false);
}

  // ================= UPDATE =================
  Future<void> updateDuty() async {
    if (editingDutyId == null || selectedCaretakerId == null) return;
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await AuthService.put("chief-warden/caretaker/update/$editingDutyId/", {
        "caretaker": selectedCaretakerId,
        "block": blocks[selectedBlock],
        "shift": shifts[selectedShift],
        "duty_date": dateController.text,
      }, widget.token, );

      await fetchDuties();
      clearForm();
    } catch (e) {
      debugPrint("Update error: $e");
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // ================= DELETE =================
  Future<void> deleteDuty(int id) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await AuthService.delete("chief-warden/caretaker/delete/$id/", widget.token, );
      await fetchDuties();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // ================= CLEAR =================
  void clearForm() {
    selectedCaretakerId = null;
    selectedBlock = null;
    selectedShift = null;
    dateController.clear();
    editingDutyId = null;
    setState(() {});
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Caretaker Assignment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= FORM =================
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Caretaker dropdown
                    DropdownButtonFormField<String>(
  value: selectedCaretakerId,
  items: caretakers.map<DropdownMenuItem<String>>((c) {
    return DropdownMenuItem<String>(
      value: c['id'].toString(), // ✅ UUID as string
      child: Text(c['name'].toString()),
    );
  }).toList(),
  onChanged: (v) {
    print("Selected caretaker: $v");
    setState(() => selectedCaretakerId = v);
  },
  decoration: const InputDecoration(
    labelText: "Caretaker",
    border: OutlineInputBorder(),
  ),
),
                    const SizedBox(height: 10),

                    // Date picker
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          dateController.text =
                              picked.toIso8601String().split("T")[0];
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Select Date",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Block
                    DropdownButtonFormField<String>(
                      value: selectedBlock,
                      items: blocks.keys
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedBlock = v),
                      decoration: const InputDecoration(
                        labelText: "Block",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Shift
                    DropdownButtonFormField<String>(
                      value: selectedShift,
                      items: shifts.keys
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedShift = v),
                      decoration: const InputDecoration(
                        labelText: "Shift",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: assignDuty,
                            child: const Text("Assign"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: updateDuty,
                            child: const Text("Update"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: clearForm,
                            child: const Text("Clear"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= LIST =================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : duties.isEmpty
                      ? const Center(child: Text("No Assignments"))
                      : ListView.builder(
                          itemCount: duties.length,
                          itemBuilder: (context, index) {
                            final duty = duties[index];

                            return Card(
                              child: ListTile(
                                title: Text(
                                    "Caretaker: ${duty['caretaker']}"),
                                subtitle: Text(
                                    "${duty['block']} | ${duty['shift']} | ${duty['duty_date']}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        editingDutyId = duty['id'];
                                        selectedCaretakerId =
                                            duty['caretaker'];
                                        selectedBlock = duty['block'];
                                        selectedShift = duty['shift'];
                                        dateController.text =
                                            duty['duty_date'];
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          deleteDuty(duty['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}