from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from .models import User
from .serializers import UserSerializer, UserCreateSerializer


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


# GET /api/users/me/
# Returns the profile of the currently logged-in user.
# Flutter calls this right after login to get the role and navigate accordingly.
class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)


# GET /api/users/
# Returns the full list of users — used by the CEO on the Utilisateurs page.
class UserListView(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]


# POST /api/users/create/
# Creates a new user account. Uses UserCreateSerializer so the password
# is hashed via set_password() before being stored.
class UserCreateView(generics.CreateAPIView):
    serializer_class = UserCreateSerializer
    permission_classes = [IsAuthenticated]


# GET  /api/users/<uuid>/  — fetch a single user's details
# PUT  /api/users/<uuid>/  — update name, phone, email, role
# DELETE /api/users/<uuid>/ — permanently remove a user account
class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]


# POST /api/users/<uuid>/toggle-active/
# Flips is_active between True and False.
# The CEO uses this to suspend or reactivate an account without deleting it.
class UserToggleActiveView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, _request, pk):
        try:
            user = User.objects.get(pk=pk)
        except User.DoesNotExist:
            return Response({"detail": "Utilisateur introuvable."}, status=status.HTTP_404_NOT_FOUND)
        user.is_active = not user.is_active
        user.save()
        return Response({"is_active": user.is_active}, status=status.HTTP_200_OK)
