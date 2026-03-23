from django.utils import timezone

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q, Count
from attendance.models import Attendance
from hostel.models import EmergencyAlert, PermissionRequest
class ApprovePermissionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        permission = PermissionRequest.objects.get(id=pk)
        permission.status = "APPROVED"
        permission.save()
        return Response({"message": "Approved"})
    
class ViolationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ["BLOCK_WARDEN", "CARETAKER"]:
            return Response({"error": "Unauthorized"}, status=403)

        today = timezone.localdate()
        user = request.user
        if user.role == "BLOCK_WARDEN":
            block = request.user.warden_profile.block
            records = Attendance.objects.filter(
                student__student_profile__block = block
            )
        else:
            records = Attendance.objects.all()
        records = records.filter(date=today).filter(
            Q(status="LATE") |
            Q(status="ABSENT") |
            Q(movement_state="LEFT")
        )

        data = []
        for r in records:
            data.append({
                "student": r.student.get_username(),
                "status": r.status,
                "left_block": r.left_block
            })

        return Response(data)

class ApprovedStudentsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ["WARDEN", "CARETAKER"]:
            return Response({"error": "Unauthorized"}, status=403)

        today = timezone.localdate()

        records = PermissionRequest.objects.filter(
            status="APPROVED",
            date=today
        )

        data = []
        for r in records:
            data.append({
                "student": r.student.get_username(),
                "type": r.permission_type
            })

        return Response(data)

class LibraryMonitorView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in  ["WARDEN", "CARETAKER"]:
            return Response({"error": "Unauthorized"}, status=403)

        today = timezone.localdate()

        records = PermissionRequest.objects.filter(
            permission_type__iexact="library",
            date=today
        )

        data = []
        for r in records:
            data.append({
                "student": r.student.get_username(),
                "type": r.permission_type,
                "status": r.status
            })

        return Response(data)

class EmergencyView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        alerts = EmergencyAlert.objects.filter(resolved=False).order_by("-created_at")

        data = []
        for a in alerts:
            data.append({
                "id": a.id,
                "student": a.student.get_username(),
                "message": a.message,
                "time": a.created_at,
            })

        return Response(data)

    def post(self, request):
        EmergencyAlert.objects.create(
            student=request.user,
            message=request.data.get("message", "Emergency triggered")
        )
        return Response({"message": "Emergency sent"}, status=201)

    def patch(self, request):
        alert_id = request.data.get("id")

        try:
            alert = EmergencyAlert.objects.get(id=alert_id)
            alert.resolved = True
            alert.save()

            return Response({"message": "Resolved"})
        except EmergencyAlert.DoesNotExist:
            return Response({"error": "Not found"}, status=404)

class DailyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        if not hasattr(user, "warden_profile"):
            return Response({"error": "Warden profile not set"}, status=400)

        block = user.warden_profile.block
        today = timezone.localdate()

        records = Attendance.objects.filter(
            student__student_profile__block=block,
            date=today
        )

        report = records.aggregate(
            total=Count("id"),
            present=Count("id", filter=Q(status="PRESENT")),
            late=Count("id", filter=Q(status="LATE")),
            absent=Count("id", filter=Q(status="ABSENT")),
            left=Count("id", filter=Q(movement_state="LEFT")),
        )

        return Response(report)

from datetime import date

class MonthlyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        block = user.warden_profile.block

        today = date.today()

        records = Attendance.objects.filter(
            student__student_profile__block=block,
            date__year=today.year,
            date__month=today.month
        )

        summary = records.values("student__roll_no").annotate(
            present=Count("id", filter=Q(status="PRESENT")),
            late=Count("id", filter=Q(status="LATE")),
            absent=Count("id", filter=Q(status="ABSENT")),
            total=Count("id")
        )

        data = []

        for s in summary:
            total = s["total"] if s["total"] else 1
            percentage = (s["present"] / total) * 100

            data.append({
                "roll_no": s["student__roll_no"],
                "present": s["present"],
                "late": s["late"],
                "absent": s["absent"],
                "percentage": round(percentage, 2)
            })

        return Response(data)

from hostel.models import Violation

class ViolationReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        block = user.warden_profile.block

        violations = Violation.objects.filter(
            student__student_profile__block=block
        ).order_by("-created_at")

        data = []

        for v in violations:
            data.append({
                "student": v.student.roll_no,
                "type": v.violation_type,
                "description": v.description,
                "date": v.created_at,
                "resolved": v.resolved
            })

        return Response(data)

import csv
from django.http import HttpResponse

class DownloadReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        if user.role != "BLOCK_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        block = user.warden_profile.block

        records = Attendance.objects.filter(
            student__student_profile__block=block
        )

        response = HttpResponse(content_type="text/csv")
        response["Content-Disposition"] = 'attachment; filename="attendance_report.csv"'

        writer = csv.writer(response)
        writer.writerow(["Roll No", "Date", "Status", "Left Block"])

        for r in records:
            writer.writerow([
                r.student.roll_no,
                r.date,
                r.status,
                r.left_block
            ])

        return response