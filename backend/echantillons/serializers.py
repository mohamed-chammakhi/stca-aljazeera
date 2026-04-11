from rest_framework import serializers
from .models import Echantillon


class EchantillonSerializer(serializers.ModelSerializer):
    # ── Denormalized read-only annotations ────────────────────────────────────
    fournisseur_id  = serializers.UUIDField(source='fournisseur.id',  read_only=True)
    collecteur_id   = serializers.UUIDField(source='collecteur.id',   read_only=True)
    code_fournisseur = serializers.CharField(source='fournisseur.code_fournisseur', read_only=True)
    fournisseur_nom  = serializers.CharField(source='fournisseur.nom',              read_only=True)
    collecteur_nom   = serializers.SerializerMethodField()
    image_url        = serializers.SerializerMethodField()

    # ── Writable FK fields (accept UUIDs on write) ────────────────────────────
    fournisseur = serializers.PrimaryKeyRelatedField(
        queryset=__import__('fournisseurs.models', fromlist=['Fournisseur']).Fournisseur.objects.all(),
        write_only=True,
    )
    collecteur = serializers.PrimaryKeyRelatedField(
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.filter(role='collecteur'),
        write_only=True,
    )

    class Meta:
        model = Echantillon
        fields = [
            'id', 'ref',
            'fournisseur', 'fournisseur_id', 'code_fournisseur', 'fournisseur_nom',
            'collecteur',  'collecteur_id',  'collecteur_nom',
            'gouvernorat', 'delegation', 'cite',
            'reference_bouteille', 'scellage', 'variete', 'quantite_estimee', 'image_url',
            'statut_collecteur', 'statut_degustateur', 'statut_labo', 'statut_ceo',
            'recu_physiquement', 'date_arrivee_echantillon',
            'budget_negociation', 'quantite_cible_t', 'camion_reserve',
            'note_interne', 'raison_refus',
            'stock_arrive', 'date_livraison_stock',
            'classification', 'remarques',
            'date_ajout', 'updated_at',
        ]
        read_only_fields = [
            'id', 'ref', 'date_ajout', 'updated_at',
            'fournisseur_id', 'code_fournisseur', 'fournisseur_nom',
            'collecteur_id', 'collecteur_nom',
        ]

    def get_collecteur_nom(self, obj):
        return f'{obj.collecteur.prenom} {obj.collecteur.nom}'

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image_url and request:
            return request.build_absolute_uri(obj.image_url.url)
        return None
