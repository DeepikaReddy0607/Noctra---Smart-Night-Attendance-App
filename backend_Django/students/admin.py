from django.contrib import admin
from .models import StudentProfile

@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "block",
        "room_number",
        "created_at",
    )
    list_filter = ("block",)
    search_fields = ("user__roll_no","room_number")
