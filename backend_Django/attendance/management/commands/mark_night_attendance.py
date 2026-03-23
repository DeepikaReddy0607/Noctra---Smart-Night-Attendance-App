from django.core.management.base import BaseCommand
from django.utils import timezone
from accounts.models import User
from attendance.models import Attendance
from students.models import StudentProfile


class Command(BaseCommand):
    help = "Marks NOT_MARKED or ABSENT for students who didn't mark attendance"

    def handle(self, *args, **kwargs):

        now = timezone.localtime()
        today = now.date()

        active_students = User.objects.filter(
            role="STUDENT",
            status="ACTIVE",
            is_active=True
        )

        created_count = 0

        for student in active_students:

            # Skip if attendance already exists
            if Attendance.objects.filter(student=student, date=today).exists():
                continue

            # TODO: Replace this with real outing check later
            in_outing = False

            if in_outing:
                status_value = "ABSENT"
            else:
                status_value = "NOT_MARKED"

            Attendance.objects.create(
                student=student,
                date=today,
                status=status_value,
            )

            created_count += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Attendance auto-evaluation completed. {created_count} records created."
            )
        )