from django.urls import path
from .views import *

urlpatterns = [
    path("assign/", AssignCaretakerView.as_view()),
    path("list/", CaretakerDutyListView.as_view()),
    path("update/<int:pk>/", UpdateCaretakerDutyView.as_view()),
    path("delete/<int:pk>/", DeleteCaretakerDutyView.as_view()),
    path("workload/", CaretakerWorkloadView.as_view()),
    path("dashboard/", ChiefWardenDashboardView.as_view()),
    path("block-stats/", BlockWiseStatsView.as_view()),
    path("violations/", ViolationSummaryView.as_view()),
]