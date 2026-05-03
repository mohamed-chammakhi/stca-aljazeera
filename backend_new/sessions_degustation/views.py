from django.db import transaction
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import SessionDegustation
from .serializers import SessionDegustationSerializer
from users.permissions import IsChefPanel


# Handles two things:
# GET /api/sessions/       → returns list of all sessions
# POST /api/sessions/      → creates a new session
class SessionListCreateView(generics.ListCreateAPIView):
    serializer_class = SessionDegustationSerializer
    permission_classes = [IsAuthenticated]  # must be logged in to access

    # Returns all sessions, newest first
    def get_queryset(self):
        return SessionDegustation.objects.select_related('cree_par').order_by('-date_creation')

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


class SessionApprouverView(APIView):
    permission_classes = [IsAuthenticated, IsChefPanel]

    def post(self, request, pk):
        with transaction.atomic():
            try:
                session = SessionDegustation.objects.select_for_update().get(pk=pk)
            except SessionDegustation.DoesNotExist:
                return Response({'detail': 'Session introuvable.'}, status=status.HTTP_404_NOT_FOUND)
            if session.statut != SessionDegustation.Statut.EN_ATTENTE_VALIDATION:
                return Response(
                    {'detail': 'Seules les sessions en attente peuvent être approuvées.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            session.statut = SessionDegustation.Statut.PLANIFIEE
            session.save()
        return Response(SessionDegustationSerializer(session).data)


class SessionRefuserView(APIView):
    permission_classes = [IsAuthenticated, IsChefPanel]

    def post(self, request, pk):
        with transaction.atomic():
            try:
                session = SessionDegustation.objects.select_for_update().get(pk=pk)
            except SessionDegustation.DoesNotExist:
                return Response({'detail': 'Session introuvable.'}, status=status.HTTP_404_NOT_FOUND)
            if session.statut != SessionDegustation.Statut.EN_ATTENTE_VALIDATION:
                return Response(
                    {'detail': 'Seules les sessions en attente peuvent être refusées.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            session.statut = SessionDegustation.Statut.REFUSEE
            session.save()
        return Response(SessionDegustationSerializer(session).data)
