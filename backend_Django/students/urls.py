from django.urls import path
from .views import AssignHostelView, StudentDashboardView, StudentPermissionView

urlpatterns = [
    path("assign-hostel/", AssignHostelView.as_view()),
    path("dashboard/", StudentDashboardView.as_view()),
    
]
