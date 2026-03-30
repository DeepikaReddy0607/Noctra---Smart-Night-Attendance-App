from django.db import models
from django.utils import timezone
from accounts.models import User


class Attendance(models.Model):

    STATUS_CHOICES = (
        ("ON_TIME", "On Time"),
        ("LATE", "Late"),
        ("ABSENT", "Absent"),
        ("NOT_MARKED", "Not Marked"),
    )

    MOVEMENT_STATE_CHOICES = (
        ("INSIDE", "Inside Hostel"),
        ("TEMP_LEFT", "Temporarily Left"),
        ("VIOLATION", "Violation Confirmed"),
    )

    student = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="attendances"
    )

    date = models.DateField()
    block = models.CharField(max_length=50)
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES
    )

    marked_at = models.DateTimeField(auto_now_add=True)

    movement_state = models.CharField(
        max_length=20,
        choices=MOVEMENT_STATE_CHOICES,
        default="INSIDE"
    )

    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    class Meta:
        unique_together = ("student", "date")

    def __str__(self):
        return f"{self.student.roll_no} - {self.date} - {self.status}"

