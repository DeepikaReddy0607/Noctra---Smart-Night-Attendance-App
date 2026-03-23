from django.urls import path
from .views import DailyReportView, DownloadReportView, EmergencyView, LibraryMonitorView, MonthlyReportView, ViolationReportView, ViolationsView, ApprovedStudentsView, ApprovePermissionView

urlpatterns = [
    path('library-monitor/', LibraryMonitorView.as_view()),
    path('violations/', ViolationsView.as_view()),
    path('approved-students/', ApprovedStudentsView.as_view()),
    path('permissions/<int:pk>/approve/', ApprovePermissionView.as_view()),
    path('emergency/', EmergencyView.as_view()),
    path("reports/daily/", DailyReportView.as_view()),
    path("reports/monthly/", MonthlyReportView.as_view()),
    path("reports/violations/", ViolationReportView.as_view()),
    path("reports/download/", DownloadReportView.as_view()),
]