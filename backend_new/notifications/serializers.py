from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    echantillon_reference = serializers.SerializerMethodField()
    echantillon_numero = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = [
            'id',
            'type',
            'titre',
            'message',
            'echantillon',
            'echantillon_reference',
            'echantillon_numero',
            'section',
            'is_read',
            'date_creation',
        ]
        read_only_fields = [
            'id', 'type', 'titre', 'message', 'echantillon',
            'echantillon_reference', 'echantillon_numero',
            'section', 'date_creation',
        ]

    def get_echantillon_reference(self, obj):
        if obj.echantillon:
            return obj.echantillon.reference_bouteille or obj.echantillon.numero
        return None

    def get_echantillon_numero(self, obj):
        if obj.echantillon:
            return obj.echantillon.numero
        return None
