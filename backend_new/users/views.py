from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import User
from .serializers import UserSerializer, UserCreateSerializer


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
