class CaretakerDashboardModel {
  final String block;
  final String shift;
  final int totalStudents;
  final int present;
  final int late;
  final int absent;
  final List lateStudents;
  final List absentStudents;
  final List libraryStudents;

  CaretakerDashboardModel({
    required this.block,
    required this.shift,
    required this.totalStudents,
    required this.present,
    required this.late,
    required this.absent,
    required this.lateStudents,
    required this.absentStudents,
    required this.libraryStudents,
  });

  factory CaretakerDashboardModel.fromJson(Map<String, dynamic> json) {
    return CaretakerDashboardModel(
      block: json["block"] ?? "",
      shift: json["shift"] ?? "",

      totalStudents: json["total_students"] ?? 0,
      present: json["present"] ?? 0,
      late: json["late"] ?? 0,
      absent: json["absent"] ?? 0,

      lateStudents: json["late_students"] ?? [],
      absentStudents: json["absent_students"] ?? [],
      libraryStudents: json["library_students"] ?? [],
    );
  }
}