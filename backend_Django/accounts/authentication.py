from rest_framework_simplejwt.authentication import JWTAuthentication

class AllowInactiveJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        user = super().get_user(validated_token)
        # 🔓 Allow inactive users during onboarding
        return user
