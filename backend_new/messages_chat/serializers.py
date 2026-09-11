from rest_framework import serializers

from echantillons.models import Echantillon

from .models import Message
from .permissions import roles_contacts_autorises


class ContactSerializer(serializers.Serializer):
    id = serializers.UUIDField(read_only=True)
    nom = serializers.CharField(read_only=True)
    prenom = serializers.CharField(read_only=True)
    role = serializers.CharField(read_only=True)


class MessageSerializer(serializers.ModelSerializer):
    contenu = serializers.CharField(required=False, allow_blank=True, default='')
    echantillon = serializers.PrimaryKeyRelatedField(
        queryset=Echantillon.objects.all(),
        required=False,
        allow_null=True,
    )
    is_read = serializers.BooleanField(source='lu', read_only=True)
    horodatage = serializers.DateTimeField(source='date_envoi', read_only=True)
    expediteur_nom = serializers.SerializerMethodField(read_only=True)
    destinataire_nom = serializers.SerializerMethodField(read_only=True)
    echantillon_numero = serializers.SerializerMethodField(read_only=True)
    echantillon_reference_bouteille = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Message
        fields = [
            'id', 'expediteur', 'destinataire',
            'contenu', 'photo_url', 'echantillon',
            'echantillon_numero', 'echantillon_reference_bouteille',
            'modifie', 'modifie_le',
            'lu', 'lu_le', 'date_envoi',
            'is_read', 'horodatage',
            'expediteur_nom', 'destinataire_nom',
        ]
        read_only_fields = [
            'id', 'expediteur', 'photo_url',
            'echantillon_numero', 'echantillon_reference_bouteille',
            'modifie', 'modifie_le',
            'lu', 'lu_le', 'date_envoi',
            'is_read', 'horodatage', 'expediteur_nom', 'destinataire_nom',
        ]

    def validate(self, attrs):
        request = self.context.get('request')
        has_uploaded_photo = bool(request and request.FILES.get('image'))
        contenu = attrs.get('contenu')
        if contenu is None and self.instance is not None:
            contenu = self.instance.contenu
        photo_url = self.instance.photo_url if self.instance is not None else ''

        if not (str(contenu or '').strip() or has_uploaded_photo or photo_url):
            raise serializers.ValidationError(
                {'contenu': ['Le message doit contenir un texte ou une photo.']}
            )
        return attrs

    def validate_destinataire(self, value):
        if not value or not value.is_active:
            raise serializers.ValidationError('Destinataire introuvable ou inactif.')

        request = self.context.get('request')
        if not request:
            return value

        if value == request.user:
            raise serializers.ValidationError('Impossible de vous envoyer un message.')

        roles_autorises = roles_contacts_autorises(request.user)
        if not roles_autorises:
            raise serializers.ValidationError("Vous n'avez pas de messagerie.")

        if value.role not in roles_autorises:
            raise serializers.ValidationError('Vous ne pouvez pas ecrire a ce contact.')

        return value

    def get_expediteur_nom(self, obj):
        return self._full_name(obj.expediteur)

    def get_destinataire_nom(self, obj):
        return self._full_name(obj.destinataire)

    def get_echantillon_numero(self, obj):
        if not obj.echantillon:
            return None
        return obj.echantillon.numero

    def get_echantillon_reference_bouteille(self, obj):
        if not obj.echantillon:
            return None
        return obj.echantillon.reference_bouteille

    def _full_name(self, user):
        if not user:
            return None
        return f"{user.prenom} {user.nom}".strip()
