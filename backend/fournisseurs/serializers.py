from rest_framework import serializers
from .models import Fournisseur


class FournisseurSerializer(serializers.ModelSerializer):
    nb_echantillons_soumis = serializers.SerializerMethodField()
    nb_achats_confirmes    = serializers.SerializerMethodField()

    class Meta:
        model = Fournisseur
        fields = [
            'id', 'code_fournisseur', 'nom', 'region',
            'telephone', 'email', 'adresse', 'notes',
            'date_premiere_contact',
            'nb_echantillons_soumis', 'nb_achats_confirmes',
        ]
        read_only_fields = ['id', 'nb_echantillons_soumis', 'nb_achats_confirmes']

    def get_nb_echantillons_soumis(self, obj):
        return obj.nb_echantillons_soumis

    def get_nb_achats_confirmes(self, obj):
        return obj.nb_achats_confirmes
