from rest_framework import serializers
from .models import Fournisseur


class FournisseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fournisseur
        fields = [
            'id',
            'nom', 'region', 'delegation', 'telephone', 'email', 'adresse', 'notes',
            'date_premiere_contact', 'date_creation',
        ]
        read_only_fields = ['id', 'date_creation']
