from rest_framework import serializers
from .models import SessionDegustation


class SessionDegustationSerializer(serializers.ModelSerializer):
    class Meta:
        model = SessionDegustation
        fields = [
            'id', 'titre', 'date', 'heure', 'lieu',
            'notes', 'statut', 'cree_par',
            'participants', 'echantillons',
            'date_creation',
        ]
