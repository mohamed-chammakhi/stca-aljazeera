from rest_framework import serializers
from .models import EvaluationOrganoleptique


class EvaluationOrganoleptiqueSérializer(serializers.ModelSerializer):
    # ── Read-only annotations ─────────────────────────────────────────────────
    echantillon_id = serializers.UUIDField(source='echantillon.id', read_only=True)
    tasteur_id     = serializers.UUIDField(source='tasteur.id',     read_only=True)
    session_id     = serializers.UUIDField(source='session.id',     read_only=True, allow_null=True)
    tasteur_nom    = serializers.SerializerMethodField()

    # ── Writable FK fields ────────────────────────────────────────────────────
    echantillon = serializers.PrimaryKeyRelatedField(
        queryset=__import__('echantillons.models', fromlist=['Echantillon']).Echantillon.objects.all(),
        write_only=True,
    )
    tasteur = serializers.PrimaryKeyRelatedField(
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.filter(role='degustateur'),
        write_only=True,
    )
    session = serializers.PrimaryKeyRelatedField(
        queryset=__import__('sessions_degustation.models', fromlist=['SessionDegustation']).SessionDegustation.objects.all(),
        write_only=True,
        required=False,
        allow_null=True,
    )

    class Meta:
        model = EvaluationOrganoleptique
        fields = [
            'id',
            'echantillon', 'echantillon_id',
            'tasteur',     'tasteur_id',  'tasteur_nom',
            'session',     'session_id',
            'classification', 'soumis_le',
            'fruite', 'fruite_vert', 'amertume', 'piquant',
            'chome', 'moisi', 'vinaigre', 'gele', 'rance',
            'autres_defaut', 'autres_defaut_nom',
            'commentaire',
        ]
        read_only_fields = ['id', 'soumis_le', 'echantillon_id', 'tasteur_id', 'session_id', 'tasteur_nom']

    def get_tasteur_nom(self, obj):
        return f'{obj.tasteur.prenom} {obj.tasteur.nom}'
