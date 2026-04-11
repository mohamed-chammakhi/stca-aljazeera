from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import User
from .serializers import (
    UserSerializer, UserCreateSerializer, UserUpdateSerializer,
    CustomTokenObtainPairSerializer,
)
from .permissions import IsDirection


class LoginView(TokenObtainPairView):
    """POST /api/auth/login/ — returns access + refresh tokens + user profile."""
    serializer_class = CustomTokenObtainPairSerializer
    permission_classes = [AllowAny]


class UserListCreateView(generics.ListCreateAPIView):
    """
    GET  /api/users/ — Direction: list all users; others: see all (read-only).
    POST /api/users/ — Direction only: create a new user.
    """
    queryset = User.objects.filter(is_active=True).order_by('nom')

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return UserCreateSerializer
        return UserSerializer

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsDirection()]
        return [IsAuthenticated()]


class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    GET    /api/users/<id>/ — any authenticated user.
    PATCH  /api/users/<id>/ — Direction or self.
    DELETE /api/users/<id>/ — Direction only (soft-delete via is_active=False).
    """
    queryset = User.objects.all()

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return UserUpdateSerializer
        return UserSerializer

    def get_permissions(self):
        if self.request.method == 'DELETE':
            return [IsDirection()]
        return [IsAuthenticated()]

    def perform_destroy(self, instance):
        # Soft-delete: deactivate instead of hard-deleting.
        instance.is_active = False
        instance.save()


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me(request):
    """GET /api/users/me/ — returns the authenticated user's profile."""
    serializer = UserSerializer(request.user, context={'request': request})
    return Response(serializer.data)
