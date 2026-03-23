from datetime import timedelta
import hashlib
import random

from django.utils import timezone
from django.contrib.auth import authenticate

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.generics import ListAPIView, UpdateAPIView
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import (
    LoginSerializer,
    MeSerializer,
    StudentRegistrationSerializer,
)
from .models import User, OTPVerification
from students.models import StudentProfile
from accounts.services.authority import resolve_authority


# =========================================
# STEP 1 — PASSWORD LOGIN (SENDS OTP)
# =========================================

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]

        # Enforce admin approval
        if user.status != "ACTIVE":
            return Response(
                {"error": "Account not approved yet"},
                status=status.HTTP_403_FORBIDDEN,
            )

        # Student must have profile
        if user.role == "STUDENT":
            if not StudentProfile.objects.filter(user=user).exists():
                return Response(
                    {"error": "Student profile missing"},
                    status=status.HTTP_403_FORBIDDEN,
                )

        # Generate OTP
        otp = str(random.randint(100000, 999999))
        otp_hash = hashlib.sha256(otp.encode()).hexdigest()

        # Remove previous login OTP
        OTPVerification.objects.filter(
            roll_no=user.roll_no,
            purpose="LOGIN"
        ).delete()

        OTPVerification.objects.create(
            roll_no=user.roll_no,
            otp_hash=otp_hash,
            purpose="LOGIN",
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        # DEV ONLY
        print(f"[LOGIN OTP] {user.roll_no}: {otp}")

        return Response(
            {"message": "OTP sent successfully"},
            status=status.HTTP_200_OK,
        )


# =========================================
# STEP 2 — VERIFY OTP + ISSUE JWT
# =========================================

class VerifyOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        roll_no = request.data.get("roll_no")
        otp = request.data.get("otp")

        if not roll_no or not otp:
            return Response(
                {"error": "roll_no and otp required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            record = OTPVerification.objects.get(
                roll_no=roll_no,
                purpose="LOGIN"
            )
        except OTPVerification.DoesNotExist:
            return Response(
                {"error": "OTP not found"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if record.expires_at < timezone.now():
            record.delete()
            return Response(
                {"error": "OTP expired"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp_hash = hashlib.sha256(otp.encode()).hexdigest()

        if otp_hash != record.otp_hash:
            return Response(
                {"error": "Invalid OTP"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user = User.objects.get(roll_no=roll_no)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Enforce approval again (defense layer)
        if user.status != "ACTIVE":
            return Response(
                {"error": "Account not approved"},
                status=status.HTTP_403_FORBIDDEN,
            )

        record.delete()

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access_token": str(refresh.access_token),
                "refresh_token": str(refresh),
                "user": MeSerializer(user).data,
            },
            status=status.HTTP_200_OK,
        )


# =========================================
# LOGOUT (JWT IS STATELESS)
# =========================================

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response(
            {"detail": "Logged out successfully"},
            status=status.HTTP_200_OK,
        )


# =========================================
# CURRENT USER INFO
# =========================================

class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = MeSerializer(request.user)
        return Response(serializer.data)


# =========================================
# AUTHORITY-BASED USER INFO
# =========================================

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def me(request):
    user = request.user
    authority = resolve_authority(user)

    return Response({
        "id": str(user.id),
        "roll_no": user.roll_no,
        "role": authority["role"],
        "is_caretaker": authority["is_caretaker"],
        "block": authority["block"].name if authority["block"] else None,
    })

class RegisterView(APIView):

    def post(self, request):
        serializer = StudentRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        print(serializer.errors)
        serializer.save()

        return Response(
            {"message": "Registration successful"},
            status=status.HTTP_201_CREATED,
        )

class PendingStudentsView(ListAPIView):
    permission_classes = [IsAdminUser]
    serializer_class = MeSerializer

    def get_queryset(self):
        return User.objects.filter(role="STUDENT", status="PENDING")


class ApproveStudentView(UpdateAPIView):
    permission_classes = [IsAdminUser]
    queryset = User.objects.filter(role="STUDENT")
    serializer_class = MeSerializer

    def patch(self, request, *args, **kwargs):
        user = self.get_object()
        user.status = "ACTIVE"
        user.save()
        return Response({"message": "Student approved"})