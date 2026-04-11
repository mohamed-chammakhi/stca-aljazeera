from rest_framework import serializers
from .models import AnalyseLabo, CritereAnalyse


class CritereAnalyseSerializer(serializers.ModelSerializer):
    analyse_id = serializers.UUIDField(source='analyse.id', read_only=True)
    conforme   = serializers.SerializerMethodField()

    class Meta:
        model  = CritereAnalyse
        fields = ['id', 'analyse_id', 'label', 'valeur', 'unite', 'seuil_min', 'seuil_max', 'conforme']
        read_only_fields = ['id', 'analyse_id', 'conforme']

    def get_conforme(self, obj):
        return obj.conforme


class AnalyseLaboSerializer(serializers.ModelSerializer):
    # ── Read-only annotations ─────────────────────────────────────────────────
    echantillon_id  = serializers.UUIDField(source='echantillon.id',           read_only=True)
    technicien_id   = serializers.UUIDField(source='technicien.id',            read_only=True)
    echantillon_ref = serializers.CharField(source='echantillon.ref',          read_only=True)
    technicien_nom  = serializers.SerializerMethodField()
    photo_url       = serializers.SerializerMethodField()
    criteres        = CritereAnalyseSerializer(many=True, required=False)

    # ── Writable FK fields ────────────────────────────────────────────────────
    echantillon = serializers.PrimaryKeyRelatedField(
        queryset=__import__('echantillons.models', fromlist=['Echantillon']).Echantillon.objects.all(),
        write_only=True,
    )
    technicien = serializers.PrimaryKeyRelatedField(
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.filter(role='laboratoire'),
        write_only=True,
    )

    class Meta:
        model  = AnalyseLabo
        fields = [
            'id',
            'echantillon', 'echantillon_id', 'echantillon_ref',
            'technicien',  'technicien_id',  'technicien_nom',
            'date_analyse', 'statut', 'notes', 'photo_url',
            'numero_lot', 'origine_campagne', 'priorite',
            'notes_reception', 'submitted_at', 'created_at',
            'criteres',
        ]
        read_only_fields = [
            'id', 'echantillon_id', 'echantillon_ref',
            'technicien_id', 'technicien_nom', 'created_at',
        ]

    def get_technicien_nom(self, obj):
        return f'{obj.technicien.prenom} {obj.technicien.nom}'

    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo_url and request:
            return request.build_absolute_uri(obj.photo_url.url)
        return None

    def create(self, validated_data):
        criteres_data = validated_data.pop('criteres', [])
        analyse = AnalyseLabo.objects.create(**validated_data)
        for c in criteres_data:
            CritereAnalyse.objects.create(analyse=analyse, **c)
        return analyse

    def update(self, instance, validated_data):
        criteres_data = validated_data.pop('criteres', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if criteres_data is not None:
            # Replace all criteria — simplest approach for the current use case.
            instance.criteres.all().delete()
            for c in criteres_data:
                CritereAnalyse.objects.create(analyse=instance, **c)

        return instance
