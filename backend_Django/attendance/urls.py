from django.urls import path
from .views import ApprovePermissionView, AttendanceHistoryView, BlockAttendanceMonitorView, BlockWardenDashboardView, BlockWardenPermissionView, CaretakerApprovedStudentsView, CaretakerDashboardView, MarkAttendanceView, RejectPermissionView
from students.views import StudentPermissionView
urlpatterns = [
    path("mark/", MarkAttendanceView.as_view()),
    path("student/history/", AttendanceHistoryView.as_view()),
    path("caretaker/dashboard/", CaretakerDashboardView.as_view()),
    path("block-warden/dashboard/",BlockWardenDashboardView.as_view()),
    path("block-monitor/", BlockAttendanceMonitorView.as_view()),
    path("block-warden/permissions/",BlockWardenPermissionView.as_view()),
    path("block-warden/permissions/<int:pk>/approve/", ApprovePermissionView.as_view()),
    path("block-warden/permissions/<int:pk>/reject/",RejectPermissionView.as_view()),
    path("caretaker/approved-permissions/",CaretakerApprovedStudentsView.as_view()),
    path('student/permissions/', StudentPermissionView.as_view()),
]
