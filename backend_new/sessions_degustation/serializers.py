from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import SessionDegustation


User = get_user_model()


class SessionDegustationSerializer(serializers.ModelSerializer):
    created_by = serializers.UUIDField(source='cree_par_id', read_only=True)
    created_at = serializers.DateTimeField(source='date_creation', read_only=True)
    # The app shows who organised the session: a name, never the raw UUID.
    created_by_nom = serializers.SerializerMethodField()
    participant_ids = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role__in=('degustateur', 'chef_degustation'), is_active=True),
        many=True,
        source='participants',
        required=False,
    )
    participant_noms = serializers.SerializerMethodField()
    confirmed_participant_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        source='presences_confirmees',
        read_only=True,
    )
    confirmed_participant_noms = serializers.SerializerMethodField()
    echantillon_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        source='echantillons',
        read_only=True,
    )

    class Meta:
        model = SessionDegustation
        fields = [
            'id',
            'titre',
            'date',
            'heure',
            'lieu',
            'notes',
            'statut',
            'nombre_echantillons_prevus',
            'created_by',
            'created_by_nom',
            'created_at',
            'participant_ids',
            'participant_noms',
            'confirmed_participant_ids',
            'confirmed_participant_noms',
            'echantillon_ids',
        ]
        read_only_fields = [
            'id',
            'created_by',
            'created_by_nom',
            'created_at',
            'participant_noms',
            'confirmed_participant_ids',
            'confirmed_participant_noms',
            'echantillon_ids',
        ]

    def get_created_by_nom(self, obj):
        user = obj.cree_par
        if user is None:
            return ''
        return f'{user.prenom} {user.nom}'.strip() or user.email

    def get_participant_noms(self, obj):
        return [
            f'{participant.prenom} {participant.nom}'.strip()
            for participant in obj.participants.all()
        ]

    def get_confirmed_participant_noms(self, obj):
        return [
            f'{participant.prenom} {participant.nom}'.strip()
            for participant in obj.presences_confirmees.all()
        ]
