from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User


class UserSerializer(serializers.ModelSerializer):
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
            'date_creation',
            'last_login',
        ]
        read_only_fields = ['id', 'date_creation', 'last_login']


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
