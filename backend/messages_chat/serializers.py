from rest_framework import serializers
from .models import Message


class MessageSerializer(serializers.ModelSerializer):
    expediteur_id    = serializers.UUIDField(source='expediteur.id',    read_only=True)
    destinataire_id  = serializers.UUIDField(source='destinataire.id',  read_only=True)
    expediteur_nom   = serializers.SerializerMethodField()
    destinataire_nom = serializers.SerializerMethodField()

    expediteur   = serializers.PrimaryKeyRelatedField(
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.all(),
        write_only=True,
    )
    destinataire = serializers.PrimaryKeyRelatedField(
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.all(),
        write_only=True,
    )

    class Meta:
        model = Message
        fields = [
            'id',
            'expediteur',    'expediteur_id',    'expediteur_nom',
            'destinataire',  'destinataire_id',  'destinataire_nom',
            'contenu', 'lu', 'lu_le', 'created_at',
        ]
        read_only_fields = ['id', 'created_at', 'expediteur_id', 'expediteur_nom',
                            'destinataire_id', 'destinataire_nom']

    def get_expediteur_nom(self, obj):
        return f'{obj.expediteur.prenom} {obj.expediteur.nom}'

    def get_destinataire_nom(self, obj):
        return f'{obj.destinataire.prenom} {obj.destinataire.nom}'
