enum PermissionType {
  none,
  library,
  nonLocal,
}

class StudentPermission {
  static PermissionType activePermission = PermissionType.none;

  static DateTime? fromDate;
  static DateTime? toDate;

  static bool approved = false; 
  static DateTime? lastAttendanceDate;

  static bool isNonLocalActive(DateTime today) {
    if (activePermission != PermissionType.nonLocal) return false;
    if (!approved || fromDate == null || toDate == null) return false;
    return !today.isBefore(fromDate!) && !today.isAfter(toDate!);
  }

  static bool hasActivePermission(DateTime today) {
    if (!approved) return false;

    if (activePermission == PermissionType.library) return true;

    if (activePermission == PermissionType.nonLocal &&
        fromDate != null &&
        toDate != null) {
      return !today.isBefore(fromDate!) && !today.isAfter(toDate!);
    }
    return false;
  }
}
