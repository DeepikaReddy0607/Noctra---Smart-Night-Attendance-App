from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from accounts.models import User
from .models import StudentProfile

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from .serializers import PermissionRequestSerializer
from accounts.models import User
from .models import StudentProfile
from attendance.models import Attendance
from hostel.models import PermissionRequest
class AssignHostelView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # 🔒 Only admin/warden should do this
        if request.user.role not in ["ADMIN", "WARDEN"]:
            return Response(
                {"error": "Permission denied"},
                status=status.HTTP_403_FORBIDDEN,
            )

        roll_no = request.data.get("roll_no")
        hostel = request.data.get("hostel")
        block = request.data.get("block")
        room_number = request.data.get("room_number")

        if not all([roll_no, hostel, block, room_number]):
            return Response(
                {"error": "All fields are required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user = User.objects.get(roll_no=roll_no, role="STUDENT")
        except User.DoesNotExist:
            return Response(
                {"error": "Student not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Create profile if not exists
        profile, created = StudentProfile.objects.get_or_create(user=user)

        profile.hostel = hostel
        profile.block = block
        profile.room_number = room_number
        profile.save()

        return Response(
            {"message": "Hostel assigned successfully"},
            status=status.HTTP_200_OK,
        )

class StudentDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):

        user = request.user

        # ---------- Profile ----------
        profile = StudentProfile.objects.filter(user=user).select_related("block").first()

        block = profile.block.name if profile and profile.block else None


        # ---------- Attendance ----------
        today_attendance = (
            Attendance.objects
            .filter(student=user)
            .order_by("-date")
            .first()
        )

        attendance_status = (
            today_attendance.status if today_attendance else "NOT_MARKED"
        )


        # ---------- Attendance Percentage ----------
        total_records = Attendance.objects.filter(student=user).count()

        present_records = Attendance.objects.filter(
            student=user,
            status__in=["PRESENT", "LATE"]
        ).count()

        if total_records > 0:
            attendance_percent = round((present_records / total_records) * 100)
        else:
            attendance_percent = 0


        # ---------- Violations ----------
        violations = Attendance.objects.filter(
            student=user,
            status__in=["LATE", "ABSENT", "LEFT_BLOCK"]
        ).count()


        # ---------- Active Permissions ----------
        permissions = PermissionRequest.objects.filter(
            student=user,
            status="APPROVED"
        ).count()


        # ---------- Response ----------
        data = {
            "roll_no": user.roll_no,
            "block": block,
            "attendance_status": attendance_status,
            "attendance_percent": attendance_percent,
            "violations": violations,
            "permissions": permissions,
        }

        return Response(data)

class StudentPermissionView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        permissions = PermissionRequest.objects.filter(
            student=request.user
        )

        serializer = PermissionRequestSerializer(permissions, many=True)
        return Response(serializer.data)

    def post(self, request):
        print("REQUEST DATA:", request.data)
        data = request.data.copy()
        serializer = PermissionRequestSerializer(data=data)
        
        if serializer.is_valid():
            existing = PermissionRequest.objects.filter(
            student=request.user,
            date=serializer.validated_data['date'],
            permission_type=serializer.validated_data['permission_type']
        ).exists()

            if existing:
                return Response(
                    {"error": "Permission already applied for this date"},
                    status=400
                )
            permission_type = serializer.validated_data['permission_type']
            permission_status = "APPROVED" if permission_type == "LIBRARY" else "PENDING"
            serializer.save(student=request.user, status=permission_status)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)