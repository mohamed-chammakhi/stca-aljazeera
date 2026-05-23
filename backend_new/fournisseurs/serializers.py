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
        read_only_fields = ['id', 'date_creation']

    def validate_code_fournisseur(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError('Le code fournisseur est obligatoire.')
        return value
