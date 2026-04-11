from rest_framework import serializers
from .models import SessionDegustation


class SessionDegustationSerializer(serializers.ModelSerializer):
    # ── Read-only annotations ─────────────────────────────────────────────────
    created_by_id   = serializers.UUIDField(source='created_by.id', read_only=True)
    echantillon_ids = serializers.SerializerMethodField()
    participant_ids = serializers.SerializerMethodField()
    participant_noms = serializers.SerializerMethodField()

    # ── Writable M2M fields ───────────────────────────────────────────────────
    echantillon_ids_write = serializers.ListField(
        child=serializers.UUIDField(), write_only=True, required=False, source='echantillons'
    )
    participant_ids_write = serializers.ListField(
        child=serializers.UUIDField(), write_only=True, required=False, source='participants'
    )

    class Meta:
        model = SessionDegustation
        fields = [
            'id', 'titre', 'date', 'heure', 'lieu', 'statut', 'notes',
            'created_by_id', 'created_at',
            'echantillon_ids', 'participant_ids', 'participant_noms',
            'echantillon_ids_write', 'participant_ids_write',
        ]
        read_only_fields = ['id', 'created_by_id', 'created_at',
                            'echantillon_ids', 'participant_ids', 'participant_noms']

    def get_echantillon_ids(self, obj):
        return [str(e.id) for e in obj.echantillons.all()]

    def get_participant_ids(self, obj):
        return [str(p.id) for p in obj.participants.all()]

    def get_participant_noms(self, obj):
        return [f'{p.prenom} {p.nom}' for p in obj.participants.all()]

    def _set_m2m(self, instance, echantillon_uuids, participant_uuids):
        from echantillons.models import Echantillon
        from django.contrib.auth import get_user_model
        User = get_user_model()

        if echantillon_uuids is not None:
            instance.echantillons.set(Echantillon.objects.filter(id__in=echantillon_uuids))
        if participant_uuids is not None:
            instance.participants.set(User.objects.filter(id__in=participant_uuids, role='degustateur'))

    def create(self, validated_data):
        echantillons = validated_data.pop('echantillons', None)
        participants  = validated_data.pop('participants', None)
        session = SessionDegustation.objects.create(**validated_data)
        self._set_m2m(session, echantillons, participants)
        return session

    def update(self, instance, validated_data):
        echantillons = validated_data.pop('echantillons', None)
        participants  = validated_data.pop('participants', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        self._set_m2m(instance, echantillons, participants)
        return instance
