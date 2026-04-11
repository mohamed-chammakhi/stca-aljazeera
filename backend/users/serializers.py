from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User


class UserSerializer(serializers.ModelSerializer):
    photo_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'email', 'role',
            'nom', 'prenom', 'telephone', 'photo_url',
            'is_active', 'date_creation', 'last_login',
        ]
        read_only_fields = ['id', 'date_creation', 'last_login']

    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo_url and request:
            return request.build_absolute_uri(obj.photo_url.url)
        return None


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'password', 'role',
            'nom', 'prenom', 'telephone',
        ]
        read_only_fields = ['id']

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['nom', 'prenom', 'telephone', 'photo_url']


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Adds role, nom, prenom to the JWT payload and login response."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['role']   = user.role
        token['nom']    = user.nom
        token['prenom'] = user.prenom
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        # Also return the user profile in the response body so the Flutter app
        # can store it without a separate /me call.
        user = self.user
        data['user'] = UserSerializer(user, context=self.context).data
        return data
