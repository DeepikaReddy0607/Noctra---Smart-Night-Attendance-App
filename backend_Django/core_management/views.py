from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from attendance.models import Attendance
from hostel.models import Block, CaretakerDuty
from .serializers import CaretakerDutySerializer
from django.contrib.auth import get_user_model
from rest_framework.decorators import api_view, permission_classes
from hostel.models import CaretakerDuty
User = get_user_model()
class AssignCaretakerView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        if request.user.role != "CHIEF_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        serializer = CaretakerDutySerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        print("ERRORS:", serializer.errors)
        return Response(serializer.errors, status=400)

class CaretakerDutyListView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        if request.user.role not in ["CHIEF_WARDEN", "WARDEN"]:
            return Response({"error": "Unauthorized"}, status=403)

        date = request.GET.get("date")
        block = request.GET.get("block")

        queryset = CaretakerDuty.objects.all()

        if date:
            queryset = queryset.filter(duty_date=date)

        if block:
            queryset = queryset.filter(block_id=block)

        serializer = CaretakerDutySerializer(queryset, many=True)
        return Response(serializer.data)

class UpdateCaretakerDutyView(APIView):

    permission_classes = [IsAuthenticated]

    def put(self, request, pk):

        if request.user.role != "CHIEF_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        try:
            duty = CaretakerDuty.objects.get(pk=pk)
        except CaretakerDuty.DoesNotExist:
            return Response({"error": "Not found"}, status=404)

        serializer = CaretakerDutySerializer(duty, data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)

        return Response(serializer.errors, status=400)

class DeleteCaretakerDutyView(APIView):

    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):

        if request.user.role != "CHIEF_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        try:
            duty = CaretakerDuty.objects.get(pk=pk)
        except CaretakerDuty.DoesNotExist:
            return Response({"error": "Not found"}, status=404)

        duty.delete()
        return Response({"message": "Deleted successfully"}, status=204)
    
from django.db.models import Count


class CaretakerWorkloadView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        date = request.GET.get("date")

        queryset = CaretakerDuty.objects.all()

        if date:
            queryset = queryset.filter(duty_date=date)

        data = queryset.values("caretaker__username").annotate(
            total_blocks=Count("block")
        )

        return Response(data)

class ChiefWardenDashboardView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):
        print("\n===== DEBUG START =====")
        print("HEADERS:", dict(request.headers))
        print("AUTH HEADER:", request.headers.get("Authorization"))
        print("USER:", request.user)
        print("AUTH:", request.auth)
        print("===== DEBUG END =====\n")
        if request.user.role != "CHIEF_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        today = timezone.localdate()

        # Total students
        total_students = User.objects.filter(role="STUDENT").count()

        # Attendance stats
        attendance_today = Attendance.objects.filter(date=today)

        present = attendance_today.filter(status="PRESENT").count()
        late = attendance_today.filter(status="LATE").count()
        absent = total_students - present

        # Violations
        left_block = attendance_today.filter(movement_state="LEFT").count()

        data = {
            "total_students": total_students,
            "present": present,
            "late": late,
            "absent": absent,
            "left_block": left_block,
        }

        return Response(data)

class BlockWiseStatsView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        today = timezone.localdate()

        data = []

        blocks = Block.objects.all()

        for block in blocks:

            total_students = User.objects.filter(
                role="STUDENT",
                student_profile__block=block
            ).count()

            attendance = Attendance.objects.filter(
                date=today,
                student__student_profile__block=block
            )

            present = attendance.filter(status="PRESENT").count()
            late = attendance.filter(status="LATE").count()
            absent = total_students - present

            data.append({
                "block": block.name,
                "total_students": total_students,
                "present": present,
                "late": late,
                "absent": absent,
            })

        return Response(data)

class ViolationSummaryView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        today = timezone.localdate()

        attendance = Attendance.objects.filter(date=today)

        data = {
            "late": attendance.filter(status="LATE").values("student__roll_no"),
            "left_block": attendance.filter(movement_state="LEFT").values("student__roll_no"),
            "absent": attendance.filter(status="ABSENT").values("student__roll_no"),
        }

        return Response(data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_caretakers(request):
    caretakers = User.objects.filter(role="CARETAKER")

    data = [
        {
            "id": c.id,
            "name": c.roll_no,
        }
        for c in caretakers
    ]

    return Response(data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_assignments(request):
    assignments = CaretakerDuty.objects.all()

    data = [
        {
            "caretaker_name": a.caretaker.roll_no,
            "block": a.block,
            "date": str(a.date),
        }
        for a in assignments
    ]

    return Response(data)

from rest_framework.views import APIView

class CaretakerListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        caretakers = User.objects.filter(role="CARETAKER")

        data = [
            {
                "id": c.id,
                "name": c.roll_no,
            }
            for c in caretakers
        ]

        return Response(data)

class ActivateStudentView(APIView):
    def post(self, request, pk):
        student = User.objects.filter(id=pk).first()

        if not student:
            return Response({"error": "Not found"}, status=404)
        student.status = "Active"
        student.is_approved = True
        student.save()

        return Response({"message": "Approved"})
    
class StudentListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "CHIEF_WARDEN":
            return Response({"error": "Unauthorized"}, status=403)

        students = User.objects.filter(role="STUDENT")

        data = [
            {
                "id": str(s.id),   # UUID → string
                "name": s.username,
                "roll_no": getattr(s, "roll_no", ""),
                "status": s.status
            }
            for s in students
        ]

        return Response(data)
    
class RejectStudentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            student = User.objects.get(pk=pk, role="STUDENT")
            student.status = "Reject"
            student.save()
            return Response({"message": "Rejected"})
        except User.DoesNotExist:
            return Response({"error": "Not found"}, status=404)