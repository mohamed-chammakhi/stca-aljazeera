from rest_framework import serializers

from .models import Message


class MessageSerializer(serializers.ModelSerializer):
    is_read = serializers.BooleanField(source='lu', read_only=True)
    horodatage = serializers.DateTimeField(source='date_envoi', read_only=True)
    expediteur_nom = serializers.SerializerMethodField(read_only=True)
    destinataire_nom = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Message
        fields = [
            'id', 'expediteur', 'destinataire',
            'contenu', 'lu', 'lu_le', 'date_envoi',
            'is_read', 'horodatage',
            'expediteur_nom', 'destinataire_nom',
        ]
        read_only_fields = [
            'id', 'expediteur', 'lu', 'lu_le', 'date_envoi',
            'is_read', 'horodatage', 'expediteur_nom', 'destinataire_nom',
        ]

    def validate_destinataire(self, value):
        if not value or not value.is_active:
            raise serializers.ValidationError('Destinataire introuvable ou inactif.')

        request = self.context.get('request')
        if request and value == request.user:
            raise serializers.ValidationError('Impossible de vous envoyer un message.')
        return value

    def get_expediteur_nom(self, obj):
        return self._full_name(obj.expediteur)

    def get_destinataire_nom(self, obj):
        return self._full_name(obj.destinataire)

    def _full_name(self, user):
        if not user:
            return None
        return f"{user.prenom} {user.nom}".strip()
