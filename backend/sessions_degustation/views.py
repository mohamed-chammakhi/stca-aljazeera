from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from .models import SessionDegustation
from .serializers import SessionDegustationSerializer
from users.models import Role


class SessionViewSet(viewsets.ModelViewSet):
    """
    Tasting sessions — visible to tasters and direction.
    Only tasters can create/modify sessions.
    """
    serializer_class   = SessionDegustationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role in (Role.COLLECTEUR, Role.LABORATOIRE):
            return SessionDegustation.objects.none()
        return SessionDegustation.objects.prefetch_related('echantillons', 'participants').all()

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
