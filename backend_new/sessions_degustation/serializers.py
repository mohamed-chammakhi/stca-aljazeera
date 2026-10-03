from django.contrib.auth import get_user_model
from datetime import datetime
from django.utils import timezone
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
    can_modifier = serializers.SerializerMethodField()
    can_supprimer = serializers.SerializerMethodField()
    can_confirmer_presence = serializers.SerializerMethodField()
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
            'can_modifier',
            'can_supprimer',
            'can_confirmer_presence',
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
            'can_modifier',
            'can_supprimer',
            'can_confirmer_presence',
            'echantillon_ids',
        ]
        extra_kwargs = {
            'titre': {'required': False, 'allow_blank': True},
            'date': {'required': False, 'allow_null': True},
            'heure': {'required': False, 'allow_null': True},
            'lieu': {'required': False, 'allow_blank': True},
            'notes': {'required': False, 'allow_blank': True},
            'statut': {'required': False},
            'nombre_echantillons_prevus': {'required': False, 'allow_null': True},
        }

    def validate(self, attrs):
        if not self.instance:
            for field in ('titre', 'date'):
                if field not in attrs or attrs.get(field) in (None, ''):
                    raise serializers.ValidationError(
                        {'detail': 'Le titre et la date sont obligatoires.'}
                    )
        elif any(f in attrs and attrs.get(f) in (None, '') for f in ('titre', 'date')):
            raise serializers.ValidationError(
                {'detail': 'Le titre et la date sont obligatoires.'}
            )
        date = attrs.get('date', getattr(self.instance, 'date', None))
        heure = attrs.get('heure', getattr(self.instance, 'heure', None))
        if date and _session_datetime(date, heure) <= timezone.localtime():
            raise serializers.ValidationError({
                'detail': (
                    "La date et l'heure doivent être dans le futur."
                    if heure
                    else "La date doit être aujourd'hui ou plus tard."
                )
            })
        return attrs

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if (
            instance.statut in (
                SessionDegustation.Statut.PLANIFIEE,
                SessionDegustation.Statut.EN_COURS,
            )
            and _session_datetime(instance.date, instance.heure) < timezone.localtime()
        ):
            data['statut'] = SessionDegustation.Statut.TERMINEE
        return data

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

    def get_can_modifier(self, obj):
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        return bool(user and user.is_authenticated and obj.cree_par_id == user.id)

    def get_can_supprimer(self, obj):
        return self.get_can_modifier(obj)

    def get_can_confirmer_presence(self, obj):
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        if not user or not user.is_authenticated:
            return False
        if obj.statut not in (
            SessionDegustation.Statut.PLANIFIEE,
            SessionDegustation.Statut.EN_COURS,
        ):
            return False
        if _session_datetime(obj.date, obj.heure) < timezone.localtime():
            return False
        if obj.participants.exists() and not obj.participants.filter(pk=user.pk).exists():
            return False
        return True


def _session_datetime(date, heure):
    if heure is None:
        heure = datetime.max.time().replace(microsecond=0)
    return timezone.make_aware(
        datetime.combine(date, heure),
        timezone.get_current_timezone(),
    )
