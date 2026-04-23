from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    echantillon_reference = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = [
            'id',
            'type',
            'titre',
            'message',
            'echantillon',
            'echantillon_reference',
            'section',
            'is_read',
            'date_creation',
        ]
        read_only_fields = ['id', 'type', 'titre', 'message', 'echantillon', 'echantillon_reference', 'section', 'date_creation']

    def get_echantillon_reference(self, obj):
        if obj.echantillon:
            return obj.echantillon.ref
        return None
