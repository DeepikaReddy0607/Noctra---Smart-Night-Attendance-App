from django.contrib import admin
from .models import Notification, Device, SystemSettings, AuditLog

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ("user", "title", "type", "is_read", "created_at")
    list_filter = ("type", "is_read")


@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ("user", "is_active", "created_at")


@admin.register(SystemSettings)
class SystemSettingsAdmin(admin.ModelAdmin):
    list_display = ("attendance_time", "grace_time_minutes", "updated_at")


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ("user", "action", "created_at")
    list_filter = ("action",)