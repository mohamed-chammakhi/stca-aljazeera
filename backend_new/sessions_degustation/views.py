from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import SessionDegustation
from .serializers import SessionDegustationSerializer


# Handles two things:
# GET /api/sessions/       → returns list of all sessions
# POST /api/sessions/      → creates a new session
class SessionListCreateView(generics.ListCreateAPIView):
    serializer_class = SessionDegustationSerializer
    permission_classes = [IsAuthenticated]  # must be logged in to access

    # Returns all sessions, newest first
    def get_queryset(self):
        return SessionDegustation.objects.all().order_by('-date_creation')

    # When creating a session, automatically set cree_par to the logged-in user
    # The user doesn't need to send their own ID — Django knows who they are from the JWT token
    def perform_create(self, serializer):
        serializer.save(cree_par=self.request.user)


# Handles three things for ONE specific session (identified by its UUID in the URL):
# GET /api/sessions/<uuid>/     → returns that session's details
# PUT /api/sessions/<uuid>/     → edits that session
# DELETE /api/sessions/<uuid>/  → deletes that session
class SessionDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = SessionDegustation.objects.all()
    serializer_class = SessionDegustationSerializer
    permission_classes = [IsAuthenticated]
