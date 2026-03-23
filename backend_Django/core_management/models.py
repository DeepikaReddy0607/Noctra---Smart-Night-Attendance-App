from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Notification(models.Model):

    NOTIFICATION_TYPES = [
        ("REMINDER", "Reminder"),
        ("ALERT", "Alert"),
        ("ASSIGNMENT", "Assignment"),
        ("PERMISSION", "Permission"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="notifications")

    title = models.CharField(max_length=255)
    message = models.TextField()

    type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)

    is_read = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.title}"
    
class Device(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="devices")

    fcm_token = models.TextField()

    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} device"
    
class SystemSettings(models.Model):

    attendance_time = models.TimeField(default="22:00")
    grace_time_minutes = models.IntegerField(default=15)

    library_permission_time = models.TimeField(default="00:00")

    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if not self.pk and SystemSettings.objects.exists():
            raise Exception("Only one SystemSettings instance allowed")
        return super().save(*args, **kwargs)

    def __str__(self):
        return "System Settings"
    
class AuditLog(models.Model):

    ACTION_TYPES = [
        ("ASSIGN", "Assign"),
        ("UPDATE", "Update"),
        ("DELETE", "Delete"),
        ("APPROVE", "Approve"),
        ("REJECT", "Reject"),
    ]

    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)

    action = models.CharField(max_length=20, choices=ACTION_TYPES)

    description = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.action}"

class CaretakerWorkload(models.Model):

    caretaker = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField()

    total_blocks = models.IntegerField(default=0)

    class Meta:
        unique_together = ("caretaker", "date")