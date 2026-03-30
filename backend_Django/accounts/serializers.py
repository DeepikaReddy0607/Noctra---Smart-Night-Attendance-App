from rest_framework import serializers
from django.contrib.auth import authenticate
from django.db import transaction
from accounts.models import User
from students.models import StudentProfile
from hostel.models import Block


# ==========================
# STUDENT REGISTRATION
# ==========================

class StudentRegistrationSerializer(serializers.Serializer):
    roll_no = serializers.CharField(max_length=20)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    phone = serializers.CharField(max_length=15)

    block = serializers.CharField()
    room_number = serializers.CharField(max_length=20)
    cot_number = serializers.CharField(max_length=10)
    year = serializers.ChoiceField(choices=["1", "2", "3", "4"])

    def validate_roll_no(self, value):
        if User.objects.filter(roll_no=value).exists():
            raise serializers.ValidationError("Roll number already registered")
        return value

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already registered")
        return value

    def validate_block(self, value):
        if not Block.objects.filter(name=value).exists():
            raise serializers.ValidationError("Invalid block selected")
        return value

    @transaction.atomic
    def create(self, validated_data):
        block_name = validated_data.pop("block")
        room_number = validated_data.pop("room_number")
        cot_number = validated_data.pop("cot_number")
        year = validated_data.pop("year")
        password = validated_data.pop("password")
        phone = validated_data.pop("phone")

        user = User.objects.create_user(
            roll_no=validated_data["roll_no"],
            email=validated_data["email"],
            password=password,
            role="STUDENT",
            status="PENDING",
        )

        user.phone = phone
        user.save()

        block = Block.objects.get(name=block_name)

        StudentProfile.objects.create(
            user=user,
            block=block,
            room_number=room_number,
            cot_number=cot_number,
            year=year,
        )

        return user


# ==========================
# LOGIN
# ==========================

from django.contrib.auth.hashers import check_password
from .models import User

class LoginSerializer(serializers.Serializer):
    roll_no = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        roll_no = data["roll_no"]
        password = data["password"]

        try:
            user = User.objects.get(roll_no=roll_no)
        except User.DoesNotExist:
            raise serializers.ValidationError("Invalid roll number")

        if not user.check_password(password):
            raise serializers.ValidationError("Invalid password")

        if user.status.strip().upper() != "ACTIVE":
            raise serializers.ValidationError("Account not approved yet")

        if not user.is_active:
            raise serializers.ValidationError("Account is disabled")

        data["user"] = user
        return data
# ==========================
# CURRENT USER
# ==========================

class MeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id",
            "roll_no",
            "email",
            "name",
            "phone",
            "role",
            "status",
            "is_biometric_enabled",
        )


# ==========================
# OTP (LOGIN ONLY)
# ==========================

class VerifyOTPSerializer(serializers.Serializer):
    roll_no = serializers.CharField(max_length=20)
    otp = serializers.CharField(max_length=6)