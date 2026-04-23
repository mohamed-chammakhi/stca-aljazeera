from rest_framework import serializers
from .models import Fournisseur


class FournisseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fournisseur
        fields = [
            'id', 'code_fournisseur',
            'nom', 'region', 'telephone', 'email', 'adresse', 'notes',
            'date_premiere_contact', 'date_creation',
        ]
