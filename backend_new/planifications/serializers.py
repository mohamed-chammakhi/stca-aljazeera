from rest_framework import serializers
from .models import PlanificationArrivage, PlanificationLivraison


class PlanificationArrivageSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlanificationArrivage
        fields = [
            'id', 'echantillon', 'mode',
            'date_exacte', 'periode_debut', 'periode_fin',
        ]


class PlanificationLivraisonSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlanificationLivraison
        fields = [
            'id', 'echantillon', 'mode',
            'date_exacte', 'periode_debut', 'periode_fin',
            'heure', 'lieu', 'camion',
            'date_creation',
        ]
