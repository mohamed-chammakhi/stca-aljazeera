from rest_framework import serializers
from .models import PlanificationArrivage, PlanificationLivraison


class PlanificationArrivageSerializer(serializers.ModelSerializer):
    echantillon_id = serializers.UUIDField(source='echantillon.id', read_only=True)
    echantillon    = serializers.PrimaryKeyRelatedField(
        queryset=__import__('echantillons.models', fromlist=['Echantillon']).Echantillon.objects.all(),
        write_only=True,
    )

    class Meta:
        model = PlanificationArrivage
        fields = ['id', 'echantillon', 'echantillon_id', 'mode', 'date_exacte', 'periode_debut', 'periode_fin']
        read_only_fields = ['id', 'echantillon_id']


class PlanificationLivraisonSerializer(serializers.ModelSerializer):
    echantillon_id = serializers.UUIDField(source='echantillon.id', read_only=True)
    echantillon    = serializers.PrimaryKeyRelatedField(
        queryset=__import__('echantillons.models', fromlist=['Echantillon']).Echantillon.objects.all(),
        write_only=True,
    )

    class Meta:
        model = PlanificationLivraison
        fields = ['id', 'echantillon', 'echantillon_id', 'mode', 'date_exacte', 'periode_debut', 'periode_fin', 'heure', 'lieu', 'camion']
        read_only_fields = ['id', 'echantillon_id']
