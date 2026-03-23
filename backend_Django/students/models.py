from django.db import models
from django.conf import settings

class StudentProfile(models.Model):

    YEAR_CHOICES = (
        ("1", "1st Year"),
        ("2", "2nd Year"),
        ("3", "3rd Year"),
        ("4", "4th Year"),
    )

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="student_profile"
    )

    block = models.ForeignKey(
        "hostel.Block",
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    room_number = models.CharField(max_length=20)
    cot_number = models.CharField(max_length=10)   # ✅ NEW FIELD
    year = models.CharField(max_length=1, choices=YEAR_CHOICES)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["block", "room_number", "cot_number"],
                name="unique_cot_per_room_per_block"
            )
        ]
    def __str__(self):
        return f"{self.user.roll_no} | {self.block} - {self.room_number} - Cot {self.cot_number}"