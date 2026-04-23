from rest_framework import serializers
from .models import Echantillon


class EchantillonSerializer(serializers.ModelSerializer):
    # Read-only display fields — Flutter expects these alongside the FK ids
    fournisseur_nom = serializers.SerializerMethodField(read_only=True)
    collecteur_nom  = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Echantillon
        fields = [
            'id', 'ref',
            'fournisseur', 'fournisseur_nom',
            'collecteur', 'collecteur_nom',
            'gouvernorat', 'delegation', 'cite',
            'variete', 'scellage', 'quantite_estimee', 'image_url',
            'statut_collecteur', 'statut_degustateur', 'statut_labo', 'statut_ceo',
            'recu_physiquement', 'date_arrivee_echantillon',
            'budget_negociation', 'quantite_cible_t', 'camion_reserve',
            'note_interne', 'raison_refus',
            'prix_final',
            'stock_arrive', 'date_livraison_stock',
            'classification', 'remarques',
            'date_ajout', 'updated_at',
        ]

    def get_fournisseur_nom(self, obj):
        return obj.fournisseur.nom if obj.fournisseur else None

    def get_collecteur_nom(self, obj):
        if obj.collecteur:
            return f"{obj.collecteur.prenom} {obj.collecteur.nom}"
        return None
