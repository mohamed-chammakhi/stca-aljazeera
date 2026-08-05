from django.db import transaction
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import SessionDegustation
from .serializers import SessionDegustationSerializer
from users.models import User
from users.permissions import IsChefDegustation, IsDegustateurOrChef


# Handles two things:
# GET /api/sessions/       → returns list of all sessions
# POST /api/sessions/      → creates a new session
class SessionListCreateView(generics.ListCreateAPIView):
    serializer_class = SessionDegustationSerializer
    permission_classes = [IsAuthenticated, IsDegustateurOrChef]

    # Returns all sessions, newest first
    def get_queryset(self):
        return (
            SessionDegustation.objects
            .select_related('cree_par')
            .prefetch_related('participants', 'presences_confirmees', 'echantillons')
            .exclude(statut=SessionDegustation.Statut.REFUSEE)
            .order_by('-date_creation')
        )

    # When creating a session, automatically set cree_par to the logged-in user
    # The user doesn't need to send their own ID — Django knows who they are from the JWT token
    def perform_create(self, serializer):
        statut = SessionDegustation.Statut.PLANIFIEE
        if self.request.user.role == User.Role.DEGUSTATEUR:
            statut = SessionDegustation.Statut.EN_ATTENTE_VALIDATION
        serializer.save(cree_par=self.request.user, statut=statut)


# Handles three things for ONE specific session (identified by its UUID in the URL):
# GET /api/sessions/<uuid>/     → returns that session's details
# PUT /api/sessions/<uuid>/     → edits that session
# DELETE /api/sessions/<uuid>/  → deletes that session
class SessionDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = (
        SessionDegustation.objects
        .select_related('cree_par')
        .prefetch_related('participants', 'presences_confirmees', 'echantillons')
    )
    serializer_class = SessionDegustationSerializer
    permission_classes = [IsAuthenticated, IsDegustateurOrChef]

    def perform_update(self, serializer):
        if self.request.user.role == User.Role.DEGUSTATEUR:
            serializer.save(statut=serializer.instance.statut)
        else:
            serializer.save()


class SessionApprouverView(APIView):
    permission_classes = [IsAuthenticated, IsChefDegustation]

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
    permission_classes = [IsAuthenticated, IsChefDegustation]

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


class SessionConfirmerPresenceView(APIView):
    permission_classes = [IsAuthenticated, IsDegustateurOrChef]

    def post(self, request, pk):
        try:
            session = SessionDegustation.objects.prefetch_related(
                'participants',
                'presences_confirmees',
            ).get(pk=pk)
        except SessionDegustation.DoesNotExist:
            return Response({'detail': 'Session introuvable.'}, status=status.HTTP_404_NOT_FOUND)
        if session.statut not in (
            SessionDegustation.Statut.PLANIFIEE,
            SessionDegustation.Statut.EN_COURS,
        ):
            return Response(
                {'detail': 'La presence ne peut etre confirmee que pour une session planifiee.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if session.participants.exists() and not session.participants.filter(pk=request.user.pk).exists():
            return Response(
                {'detail': 'Vous ne faites pas partie des participants de cette session.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        session.presences_confirmees.add(request.user)
        return Response(SessionDegustationSerializer(session).data)
