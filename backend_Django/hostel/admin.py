from django.contrib import admin
from .models import Hostel, Block, CaretakerDuty, PermissionRequest, Violation


@admin.register(Hostel)
class HostelAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "gender", "chief_warden")


@admin.register(Block)
class BlockAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "hostel", "warden", "radius_meters")


@admin.register(CaretakerDuty)
class CaretakerDutyAdmin(admin.ModelAdmin):
    list_display = ("caretaker", "block", "duty_date", "shift")


@admin.register(PermissionRequest)
class PermissionRequestAdmin(admin.ModelAdmin):
    list_display = ("student", "permission_type", "date", "status")


@admin.register(Violation)
class ViolationAdmin(admin.ModelAdmin):
    list_display = ("student", "violation_type", "created_at")