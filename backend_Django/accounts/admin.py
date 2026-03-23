from django.contrib import admin
from .models import User, OTPVerification, WardenProfile


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("roll_no", "role", "is_active", "is_staff", "created_at")
    list_filter = ("role", )
    search_fields = ("roll_no",)
    ordering = ("-created_at",)

@admin.register(OTPVerification)
class OTPVerificationAdmin(admin.ModelAdmin):
    list_display = ("roll_no", "expires_at", "created_at")
    search_fields = ("roll_no",)


@admin.register(WardenProfile)
class WardenProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "designation", "created_at")