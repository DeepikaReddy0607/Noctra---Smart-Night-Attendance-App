from django.db import models

from django.conf import settings
from django.contrib.auth import get_user_model

User = get_user_model()
class Hostel(models.Model):

    name = models.CharField(max_length=100, unique=True)

    gender = models.CharField(
        max_length=10,
        choices=(
            ("BOYS", "Boys"),
            ("GIRLS", "Girls"),
        )
    )

    chief_warden = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        related_name="hostels_managed"
    )

    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    def __str__(self):
        return self.name
    
class Block(models.Model):

    hostel = models.ForeignKey(
        Hostel,
        on_delete=models.CASCADE,
        related_name="blocks"
    )

    name = models.CharField(max_length=50)

    center_latitude = models.FloatField()
    center_longitude = models.FloatField()

    radius_meters = models.IntegerField(default=120)

    warden = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        related_name="blocks_supervised"
    )

    def __str__(self):
        return f"{self.hostel.name} - {self.name}"
    
class CaretakerDuty(models.Model):

    SHIFT_CHOICES = (
        ("MORNING", "Morning"),
        ("EVENING", "Evening"),
        ("NIGHT", "Night"),
    )

    caretaker = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        limit_choices_to={"role": "CARETAKER"},
        related_name="duties"
    )

    block = models.ForeignKey(Block, on_delete=models.CASCADE)

    duty_date = models.DateField(db_index=True)

    shift = models.CharField(
        max_length=20,
        choices=SHIFT_CHOICES
    )

    class Meta:
        unique_together = ("block", "duty_date", "shift")
    def __str__(self):
        return f"{self.caretaker} - {self.block} ({self.shift})"
    
class PermissionRequest(models.Model):

    TYPE_CHOICES = (
        ("OUTING", "Non Local Outing"),
        ("LIBRARY", "Library"),
    )

    STATUS_CHOICES = (
        ("PENDING", "Pending"),
        ("APPROVED", "Approved"),
        ("REJECTED", "Rejected"),
    )

    student = models.ForeignKey(
        User, 
        on_delete=models.CASCADE,
        related_name="permission_requests"
    )

    permission_type = models.CharField(
        max_length=20,
        choices=TYPE_CHOICES
    )

    date = models.DateField(db_index=True)

    status = models.CharField(
        max_length=20,
        default="PENDING",
        choices=STATUS_CHOICES
    )

    approved_by = models.ForeignKey(
        User,
        null=True,
        on_delete=models.SET_NULL,
        related_name="approved_permissions"
    )
    class Meta:
        unique_together = ("student", "date", "permission_type")
    def __str__(self):
        return f"{self.student} - {self.permission_type} ({self.status})"

class Violation(models.Model):

    TYPE_CHOICES = (
        ("LATE", "Late Attendance"),
        ("LEFT_BLOCK", "Left Block After Attendance"),
        ("ABSENT", "Absent Without Permission"),
    )

    student = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="violations"
    )

    block = models.ForeignKey(
        Block,
        on_delete=models.CASCADE,
        related_name="violations",
        null=True,
        blank=True
    )

    violation_type = models.CharField(
        max_length=30,
        choices=TYPE_CHOICES
    )

    description = models.TextField(blank=True)

    resolved = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=["created_at"]),
            models.Index(fields=["violation_type"]),
        ]

    def __str__(self):
        return f"{self.student} - {self.violation_type}"

class LibraryEntry(models.Model):

    student = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="library_entries"
    )

    date = models.DateField(db_index=True)

    declared_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("student", "date")

    def __str__(self):
        return f"{self.student} - Library"

class EmergencyAlert(models.Model):
    student = models.ForeignKey(User, on_delete=models.CASCADE)
    message = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    resolved = models.BooleanField(default=False)