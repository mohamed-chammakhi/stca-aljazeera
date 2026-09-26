import re

from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User


class UserSerializer(serializers.ModelSerializer):
    statut = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'nom',
            'prenom',
            'role',
            'telephone',
            'is_active',
            'statut',
            'date_creation',
            'date_suppression',
            'last_login',
        ]
        read_only_fields = [
            'id',
            'statut',
            'date_creation',
            'date_suppression',
            'last_login',
        ]

    def get_statut(self, obj):
        if obj.date_suppression is not None:
            return 'supprime'
        if obj.is_active:
            return 'actif'
        return 'desactive'


class PanelMemberSerializer(serializers.ModelSerializer):
    role = serializers.CharField(source='get_role_display', read_only=True)
    membre_depuis = serializers.SerializerMethodField()
    est_en_ligne = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'nom',
            'prenom',
            'role',
            'membre_depuis',
            'est_en_ligne',
        ]
        read_only_fields = fields

    def get_membre_depuis(self, obj):
        month_names = [
            'Jan',
            'Fev',
            'Mar',
            'Avr',
            'Mai',
            'Juin',
            'Juil',
            'Aout',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
        ]
        created = obj.date_creation
        return f'{month_names[created.month - 1]} {created.year}'

    def get_est_en_ligne(self, obj):
        return obj.is_active


class UserAdminUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['email', 'nom', 'prenom', 'role', 'telephone', 'is_active']

    def validate_email(self, value):
        value = User.objects.normalize_email(value)
        queryset = User.objects.filter(email__iexact=value)
        if self.instance is not None:
            queryset = queryset.exclude(pk=self.instance.pk)
        if queryset.exists():
            raise serializers.ValidationError('Cet email est deja utilise.')
        return value


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['email', 'nom', 'prenom', 'telephone']

    def validate_email(self, value):
        value = User.objects.normalize_email(value)
        queryset = User.objects.filter(email__iexact=value)
        if self.instance is not None:
            queryset = queryset.exclude(pk=self.instance.pk)
        if queryset.exists():
            raise serializers.ValidationError('Cet email est deja utilise.')
        return value

    def validate(self, attrs):
        protected_fields = {
            'id',
            'role',
            'is_active',
            'is_staff',
            'is_superuser',
            'password',
            'date_creation',
            'last_login',
        }
        requested_protected_fields = protected_fields.intersection(self.initial_data.keys())
        if requested_protected_fields:
            raise serializers.ValidationError({
                field: ['Ce champ ne peut pas etre modifie depuis le profil.']
                for field in sorted(requested_protected_fields)
            })
        return attrs


class ChangePasswordSerializer(serializers.Serializer):
    ancien_mot_de_passe = serializers.CharField(write_only=True, trim_whitespace=False)
    nouveau_mot_de_passe = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate_nouveau_mot_de_passe(self, value):
        if len(value) < 6 or not re.search(r'[0-9]', value) or not re.search(r'[^a-zA-Z0-9]', value):
            raise serializers.ValidationError(
                'Le mot de passe doit contenir au moins 6 caractères, un chiffre et un caractère spécial.'
            )
        return value


class ForgotPasswordRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class ForgotPasswordVerifySerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.RegexField(
        regex=r'^\d{6}$',
        error_messages={'invalid': 'Le code doit contenir 6 chiffres.'},
    )


class ForgotPasswordNewPasswordSerializer(serializers.Serializer):
    jeton = serializers.CharField()
    nouveau_mot_de_passe = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate_nouveau_mot_de_passe(self, value):
        return ChangePasswordSerializer().validate_nouveau_mot_de_passe(value)

class LoginSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['role'] = user.role
        token['nom'] = user.nom
        token['prenom'] = user.prenom
        token['email'] = user.email
        return token

    def validate(self, attrs):
        email = attrs.get(self.username_field, '')
        password = attrs.get('password', '')
        user = User.objects.filter(email__iexact=email).first()

        if user is None:
            raise serializers.ValidationError({
                'code': 'email_not_found',
                'detail': "Aucun compte n'est associe a cet email.",
            })

        if not user.check_password(password):
            raise serializers.ValidationError({
                'code': 'password_incorrect',
                'detail': 'Mot de passe incorrect.',
            })

        if not user.is_active:
            raise serializers.ValidationError({
                'code': 'account_inactive',
                'detail': 'Ce compte est desactive.',
            })

        data = super().validate(attrs)
        data['user'] = UserSerializer(self.user).data
        return data


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['id', 'email', 'nom', 'prenom', 'role', 'telephone', 'password']
        read_only_fields = ['id']

    def validate_email(self, value):
        value = User.objects.normalize_email(value)
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError('Cet email est deja utilise.')
        return value

    def create(self, validated_data):
        password = validated_data.pop('password', 'Test@12345')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user
