from django.urls import path
from .views import LoginView, LogoutView, MeView,VerifyOTPView, me, RegisterView, PendingStudentsView, ApproveStudentView

urlpatterns = [
    path("login/", LoginView.as_view()),
    path("logout/", LogoutView.as_view()),
    path("me/", MeView.as_view()),
    path("auth/me/", me),
    path("verify-otp/", VerifyOTPView.as_view()),
    path("register/", RegisterView.as_view(), name="register"),
    path("pending-students/", PendingStudentsView.as_view()),
path("approve-student/<uuid:pk>/", ApproveStudentView.as_view()),
]
