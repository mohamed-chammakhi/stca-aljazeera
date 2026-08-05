from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from .models import User
from .permissions import IsDirection
from .serializers import (
    LoginSerializer,
    PanelMemberSerializer,
    UserAdminUpdateSerializer,
    UserCreateSerializer,
    UserProfileUpdateSerializer,
    UserSerializer,
)


# POST /api/auth/login/
# Returns access + refresh JWT tokens plus the current user profile.
class LoginView(TokenObtainPairView):
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]


# POST /api/auth/logout/
# Blacklists the refresh token so it can no longer generate new access tokens.
class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({'detail': 'Token de rafraîchissement requis.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
        except TokenError:
            return Response({'detail': 'Token invalide ou déjà révoqué.'}, status=status.HTTP_400_BAD_REQUEST)
        return Response(status=status.HTTP_204_NO_CONTENT)


# GET   /api/users/me/
# PATCH /api/users/me/
# Returns or updates the profile of the currently logged-in user.
# Flutter calls this right after login to get the role and navigate accordingly.
class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = UserProfileUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(UserSerializer(request.user).data, status=status.HTTP_200_OK)


class PanelMemberListView(generics.ListAPIView):
    serializer_class = PanelMemberSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return User.objects.filter(
            role__in=[User.Role.DEGUSTATEUR, User.Role.CHEF_DEGUSTATION],
            is_active=True,
        ).order_by('nom', 'prenom', 'date_creation')


# GET /api/users/
# Returns the full list of users — used by the CEO on the Utilisateurs page.
class UserListCreateView(generics.ListCreateAPIView):
    queryset = User.objects.all().order_by('date_creation', 'nom', 'prenom')
    permission_classes = [IsDirection]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return UserCreateSerializer
        return UserSerializer

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        user = User.objects.get(pk=response.data['id'])
        return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)


# POST /api/users/create/
# Creates a new user account. Uses UserCreateSerializer so the password
# is hashed via set_password() before being stored.
class UserCreateView(generics.CreateAPIView):
    serializer_class = UserCreateSerializer
    permission_classes = [IsDirection]

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        user = User.objects.get(pk=response.data['id'])
        return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)


# GET  /api/users/<uuid>/  — fetch a single user's details
# PUT  /api/users/<uuid>/  — update name, phone, email, role
# DELETE /api/users/<uuid>/ — permanently remove a user account
class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    permission_classes = [IsDirection]

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return UserAdminUpdateSerializer
        return UserSerializer

    def perform_update(self, serializer):
        instance = serializer.instance
        if instance.pk == self.request.user.pk:
            from rest_framework.exceptions import ValidationError
            if serializer.validated_data.get('is_active') is False:
                raise ValidationError({'detail': 'Vous ne pouvez pas desactiver votre propre compte.'})
            if serializer.validated_data.get('role') not in (None, instance.role):
                raise ValidationError({'detail': 'Vous ne pouvez pas modifier votre propre role.'})
        serializer.save()

    def perform_destroy(self, instance):
        if instance.pk == self.request.user.pk:
            from rest_framework.exceptions import ValidationError
            raise ValidationError({'detail': 'Vous ne pouvez pas supprimer votre propre compte.'})
        instance.delete()


# POST /api/users/<uuid>/toggle-active/
# Flips is_active between True and False.
# The CEO uses this to suspend or reactivate an account without deleting it.
class UserToggleActiveView(APIView):
    permission_classes = [IsDirection]

    def post(self, request, pk):
        try:
            user = User.objects.get(pk=pk)
        except User.DoesNotExist:
            return Response({"detail": "Utilisateur introuvable."}, status=status.HTTP_404_NOT_FOUND)
        if user.pk == request.user.pk:
            return Response(
                {"detail": "Vous ne pouvez pas desactiver votre propre compte."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user.is_active = not user.is_active
        user.save()
        return Response(UserSerializer(user).data, status=status.HTTP_200_OK)
