import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin,BaseUserManager

from django.conf import settings
class UserManager(BaseUserManager):
    def create_user(self, roll_no, email, password=None, role="STUDENT", **extra_fields):
        if not roll_no:
            raise ValueError("Roll number is required")
        if not email:
            raise ValueError("Email is required")

        email = self.normalize_email(email)
        
        user = self.model(
            roll_no=roll_no,
            email=email,
            role=role,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, roll_no, email, password=None, **extra_fields):
        extra_fields.setdefault("role", "CHIEF_WARDEN")
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("status", "ACTIVE")
        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True")

        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True")

        return self.create_user(
            roll_no=roll_no,
            email=email,
            password=password,
            **extra_fields
        )

class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = (
        ("STUDENT", "Student"),
        ("CARETAKER", "Caretaker"),
        ("BLOCK_WARDEN", "Block Warden"),
        ("CHIEF_WARDEN", "Chief Warden"),
    )

    STATUS_CHOICES = (
        ("ACTIVE", "Active"),
        ("PENDING", "Pending"),
        ("REJECTED", "Rejected"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    roll_no = models.CharField(max_length=20, unique=True)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=15)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)

    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default="PENDING"
    )

    is_allocated = models.BooleanField(default=False)
    
    device_id = models.CharField(max_length=255, null=True, blank=True)
    device_model = models.CharField(max_length=255, null=True, blank=True)
    last_login_at = models.DateTimeField(null=True, blank=True)

    is_biometric_enabled = models.BooleanField(default=False)
    is_first_login = models.BooleanField(default=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = "roll_no"
    REQUIRED_FIELDS = ["email", "role"]

    objects = UserManager()

    def __str__(self):
        return f"{self.roll_no} ({self.role})"

class OTPVerification(models.Model):
    PURPOSE_CHOICES = (
        ("ACTIVATION", "Activation"),
        ("LOGIN", "Login"),
    )

    roll_no = models.CharField(max_length=20)
    otp_hash = models.CharField(max_length=128)
    temp_password = models.CharField(max_length=128, null=True, blank=True)
    purpose = models.CharField(max_length=20, choices=PURPOSE_CHOICES)
    expires_at = models.DateTimeField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"OTP for {self.roll_no}"

class WardenProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="warden_profile"
    )

    block = models.ForeignKey(
        "hostel.Block",
        on_delete=models.CASCADE,
        null=True,
        blank=True
    )
    
    designation = models.CharField(
        max_length=100,
        help_text="e.g. Caretaker, Warden, Chief Warden"
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.roll_no} - {self.designation}"
