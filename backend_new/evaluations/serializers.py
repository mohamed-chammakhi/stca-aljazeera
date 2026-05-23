from rest_framework import serializers
from .models import EvaluationOrganoleptique


class EvaluationSerializer(serializers.ModelSerializer):
    # Read-only display field — Flutter expects degustateur_nom alongside degustateur id
    degustateur_nom = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = EvaluationOrganoleptique
        fields = [
            'id', 'echantillon', 'degustateur', 'degustateur_nom', 'session',
            'statut', 'classification',
            'fruite', 'fruite_vert', 'amertume', 'piquant',
            'chome', 'moisi', 'vinaigre', 'rance', 'gele',
            'autres_defaut', 'autres_defaut_nom',
            'commentaire',
            'soumis_le', 'date_modification',
        ]
        read_only_fields = [
            'id', 'degustateur', 'degustateur_nom',
            'soumis_le', 'date_modification',
        ]

    def validate_echantillon(self, value):
        if not value.recu_physiquement:
            raise serializers.ValidationError(
                'L echantillon doit etre recu physiquement avant evaluation.'
            )
        return value

    def get_degustateur_nom(self, obj):
        if obj.degustateur:
            return f"{obj.degustateur.prenom} {obj.degustateur.nom}"
        return None
