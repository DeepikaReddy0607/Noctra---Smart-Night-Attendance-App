from rest_framework import serializers
from .models import StudentProfile
from hostel.models import PermissionRequest


class HostelAssignmentSerializer(serializers.Serializer):
    hostel = serializers.CharField(max_length=100)
    block = serializers.CharField(max_length=50)
    room_number = serializers.CharField(max_length=20)

class PermissionRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = PermissionRequest
        fields = ['id', 'permission_type', 'date', 'status']
        read_only_fields = ['status']
