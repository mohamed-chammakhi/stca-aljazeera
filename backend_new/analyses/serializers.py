from rest_framework import serializers
from .models import AnalyseLabo, CritereAnalyse


class CritereAnalyseSerializer(serializers.ModelSerializer):
    class Meta:
        model = CritereAnalyse
        fields = ['id', 'label', 'valeur', 'unite', 'valeur_min', 'valeur_max', 'conforme']


class AnalyseLaboSerializer(serializers.ModelSerializer):
    criteres = CritereAnalyseSerializer(many=True, read_only=True)

    class Meta:
        model = AnalyseLabo
        fields = [
            'id', 'echantillon', 'technicien', 'statut',
            'photo', 'notes', 'criteres',
            'date_analyse', 'date_modification',
        ]
