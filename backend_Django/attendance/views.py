from datetime import time
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from accounts.models import User
from hostel.models import CaretakerDuty, LibraryEntry, PermissionRequest
from students.models import StudentProfile
from .models import Attendance
from .serializers import MarkAttendanceSerializer
from .utils import calculate_distance


# -------------------------------
# Attendance Time Configuration
# -------------------------------

ATTENDANCE_START = time(20, 30)
ONTIME_CUTOFF = time(22, 0)
LATE_CUTOFF = time(22, 10)


# =====================================================
# MARK ATTENDANCE
# =====================================================

class MarkAttendanceView(APIView):

    permission_classes = [IsAuthenticated]
    print("MARK ATTENDANCE API HIT")

    def post(self, request):

        user = request.user

        # Only students allowed
        if user.role != "STUDENT":
            return Response({"error": "Only students can mark attendance"}, status=403)

        if user.status != "ACTIVE":
            return Response({"error": "Account not active"}, status=403)

        serializer = MarkAttendanceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        now = timezone.localtime()
        today = now.date()
        current_time = now.time()

        # Prevent duplicate attendance
        if Attendance.objects.filter(student=user, date=today).exists():
            return Response({"error": "Attendance already marked"}, status=400)

        # Check permission (outing)
        permission = PermissionRequest.objects.filter(
            student=user,
            date=today,
            status="APPROVED"
        ).first()

        if permission and permission.permission_type == "OUTING":
            return Response(
                {"error": "Attendance disabled due to approved outing"},
                status=403
            )

        # Attendance time validation
        if current_time < ATTENDANCE_START:
            return Response({"error": "Attendance window not started"}, status=400)

        elif ATTENDANCE_START <= current_time <= ONTIME_CUTOFF:
            status_value = "ON_TIME"

        elif ONTIME_CUTOFF < current_time <= LATE_CUTOFF:
            status_value = "LATE"

        else:
            return Response({"error": "Attendance window closed"}, status=400)

        # Student profile
        try:
            profile = user.student_profile
        except StudentProfile.DoesNotExist:
            return Response({"error": "Student profile missing"}, status=400)

        block = profile.block

        if not block:
            return Response({"error": "Student not assigned to block"}, status=400)

        # Geofence validation
        student_lat = serializer.validated_data["latitude"]
        student_lon = serializer.validated_data["longitude"]

        distance = calculate_distance(
            student_lat,
            student_lon,
            block.center_latitude,
            block.center_longitude,
        )

        if distance > block.radius_meters:
            return Response(
                {"error": "Outside hostel block boundary"},
                status=403
            )

        # Create attendance
        Attendance.objects.create(
            student=user,
            block=block,
            date=today,
            status=status_value,
            latitude=student_lat,
            longitude=student_lon,
        )

        return Response({
            "message": "Attendance marked",
            "status": status_value
        })


# =====================================================
# STUDENT ATTENDANCE HISTORY
# =====================================================

class AttendanceHistoryView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        user = request.user

        if user.role != "STUDENT":
            return Response({"error": "Unauthorized"}, status=403)

        records = Attendance.objects.filter(
            student=user
        ).order_by("-date")

        data = []

        for record in records:
            data.append({
                "date": record.date,
                "status": record.status,
                "flag": record.movement_state
            })

        return Response(data)


# =====================================================
# CARETAKER DASHBOARD
# =====================================================

class CaretakerDashboardView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        user = request.user

        if user.role != "CARETAKER":
            return Response({"error": "Unauthorized"}, status=403)

        today = timezone.now().date()

        duty = CaretakerDuty.objects.filter(
            caretaker=user,
            duty_date=today
        ).select_related("block").first()

        if not duty:
            return Response({
                "message": "No duty assigned today"
            })

        block = duty.block

        students = User.objects.filter(
            role="STUDENT",
            student_profile__block=block
        )

        attendance = Attendance.objects.filter(
            student__student_profile__block=block,
            date=today
        ).select_related("student")

        total_students = students.count()

        present = attendance.filter(status="ON_TIME").count()
        late = attendance.filter(status="LATE").count()

        absent_students = students.exclude(
            id__in=attendance.values_list("student_id", flat=True)
        )

        library_entries = LibraryEntry.objects.filter(
            student__in=students,
            date=today
        )

        response = {

            "block": block.name,
            "shift": duty.shift,

            "total_students": total_students,
            "present": present,
            "late": late,
            "absent": absent_students.count(),
            "library": library_entries.count(),

            "late_students": list(
                attendance.filter(status="LATE")
                .values("student__roll_no")
            ),

            "absent_students": list(
                absent_students.values("roll_no")
            ),

            "library_students": list(
                library_entries.values("student__roll_no")
            ),
        }

        return Response(response)


# =====================================================
# BLOCK WARDEN DASHBOARD
# =====================================================

class BlockWardenDashboardView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        block = user.blocks_supervised.first()

        if not block:
            return Response({"error": "No block assigned"}, status=400)

        today = timezone.now().date()

        students = User.objects.filter(
            role="STUDENT",
            student_profile__block=block
        )

        attendance = Attendance.objects.filter(
            student__student_profile__block=block,
            date=today
        )

        total_students = students.count()

        present = attendance.filter(status="ON_TIME").count()
        late = attendance.filter(status="LATE").count()

        absent = total_students - attendance.count()

        violations = attendance.filter(
            movement_state="VIOLATION"
        ).count()

        return Response({

            "block": block.name,

            "total_students": total_students,
            "present": present,
            "late": late,
            "absent": absent,
            "violations": violations,

            "attendance_progress": round(
                (attendance.count() / total_students) * 100, 2
            ) if total_students else 0
        })

class BlockAttendanceMonitorView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        user = request.user

        if user.role not in ["CARETAKER", "BLOCK_WARDEN"]:
            return Response({"error": "Unauthorized"}, status=403)

        if user.role == "BLOCK_WARDEN":
            block = user.blocks_supervised.first()

        else:
            duty = CaretakerDuty.objects.filter(
                caretaker=user,
                duty_date=timezone.now().date()
            ).first()

            block = duty.block if duty else None

        if not block:
            return Response({"error": "No block assigned"}, status=400)

        today = timezone.now().date()

        students = User.objects.filter(
            role="STUDENT",
            student_profile__block=block
        )

        attendance = Attendance.objects.filter(
            student__student_profile__block=block,
            date=today
        )

        late_students = attendance.filter(
            status="LATE"
        ).values("student__roll_no")

        absent_students = students.exclude(
            id__in=attendance.values_list("student_id", flat=True)
        ).values("roll_no")

        library_students = LibraryEntry.objects.filter(
            student__in=students,
            date=today
        ).values("student__roll_no")

        return Response({
            "late_students": list(late_students),
            "absent_students": list(absent_students),
            "library_students": list(library_students),
        })
    
class BlockWardenPermissionView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        block = user.blocks_supervised.first()

        students = User.objects.filter(
            role="STUDENT",
            student_profile__block=block
        )

        pending = PermissionRequest.objects.filter(
            student__in=students,
            status="PENDING"
        ).select_related("student", "student__student_profile")

        approved = PermissionRequest.objects.filter(
            student__in=students,
            status="APPROVED"
        ).select_related("student", "student__student_profile")

        rejected = PermissionRequest.objects.filter(
            student__in=students,
            status="REJECTED"
        ).select_related("student", "student__student_profile")

        def format_data(queryset):

            data = []

            for r in queryset:

                profile = getattr(r.student, "student_profile", None)

                data.append({
                    "id": r.id,
                    "roll_no": r.student.roll_no,
                    "room": profile.room_number if profile else None,
                    "cot": profile.cot_number if profile else None,
                    "type": r.permission_type,
                    "date": str(r.date),
                    "status": r.status
                })

            return data

        return Response({
            "pending": format_data(pending),
            "approved": format_data(approved),
            "rejected": format_data(rejected),
        })

class ApprovePermissionView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):

        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        try:
            permission = PermissionRequest.objects.get(id=pk)
        except PermissionRequest.DoesNotExist:
            return Response({"error": "Request not found"}, status=404)

        permission.status = "APPROVED"
        permission.approved_by = user
        permission.save()

        return Response({"message": "Permission approved"})

class RejectPermissionView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):

        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        try:
            permission = PermissionRequest.objects.get(id=pk)
        except PermissionRequest.DoesNotExist:
            return Response({"error": "Request not found"}, status=404)

        permission.status = "REJECTED"
        permission.approved_by = user
        permission.save()

        return Response({"message": "Permission rejected"})
    
class CaretakerApprovedStudentsView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        if request.user.role != "CARETAKER":
            return Response({"error": "Unauthorized"}, status=403)

        approved = PermissionRequest.objects.filter(
            status="APPROVED"
        ).select_related("student", "student__student_profile")

        data = []

        for r in approved:

            profile = getattr(r.student, "student_profile", None)

            data.append({
                "id": r.id,
                "roll_no": r.student.roll_no,
                "block": profile.block.name if profile and profile.block else None,
                "room": profile.room_number if profile else None,
                "cot": profile.cot_number if profile else None,
                "type": r.permission_type,
                "date": str(r.date),
                "status": r.status
            })

        return Response(data)