from rest_framework import serializers
from hostel.models import CaretakerDuty
from django.contrib.auth import get_user_model

User = get_user_model()


class CaretakerDutySerializer(serializers.ModelSerializer):

    caretaker_name = serializers.CharField(source="caretaker.username", read_only=True)
    block_name = serializers.CharField(source="block.name", read_only=True)

    class Meta:
        model = CaretakerDuty
        fields = "__all__"

    def validate(self, data):
        caretaker = data.get("caretaker")
        date = data.get("duty_date")
        shift = data.get("shift")

        # Count how many blocks caretaker already has
        existing = CaretakerDuty.objects.filter(
            caretaker=caretaker,
            duty_date=date,
            shift=shift
        ).count()

        # Soft warning logic (not blocking)
        if existing >= 3:
            raise serializers.ValidationError(
                f"{caretaker} already assigned to {existing} blocks in this shift"
            )

        return data
    
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):

    class Meta:
        model = Notification
        fields = "__all__"

from .models import Device


class DeviceSerializer(serializers.ModelSerializer):

    class Meta:
        model = Device
        fields = "__all__"

from .models import SystemSettings


class SystemSettingsSerializer(serializers.ModelSerializer):

    class Meta:
        model = SystemSettings
        fields = "__all__"

from .models import AuditLog


class AuditLogSerializer(serializers.ModelSerializer):

    class Meta:
        model = AuditLog
        fields = "__all__"