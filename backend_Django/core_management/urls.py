from django.urls import path
from .views import *

urlpatterns = [
    path("caretaker/assign/", AssignCaretakerView.as_view()),
    path("caretaker/list/", CaretakerDutyListView.as_view()),
    path("update/<int:pk>/", UpdateCaretakerDutyView.as_view()),
    path("delete/<int:pk>/", DeleteCaretakerDutyView.as_view()),
    path("workload/", CaretakerWorkloadView.as_view()),
    path("dashboard/", ChiefWardenDashboardView.as_view()),
    path("block-stats/", BlockWiseStatsView.as_view()),
    path("violations/", ViolationSummaryView.as_view()),
    path("caretaker/caretakers/", CaretakerListView.as_view()),
    path("activate-student/<uuid:pk>/", ActivateStudentView.as_view()),
    path("students/", StudentListView.as_view()),
path("reject-student/<uuid:pk>/", RejectStudentView.as_view()),
]