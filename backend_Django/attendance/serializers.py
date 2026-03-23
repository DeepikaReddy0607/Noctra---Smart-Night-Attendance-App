from rest_framework import serializers


class MarkAttendanceSerializer(serializers.Serializer):
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()

class StudentBasicSerializer(serializers.Serializer):

    roll_no = serializers.CharField()
    name = serializers.CharField()