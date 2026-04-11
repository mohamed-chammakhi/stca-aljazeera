from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from .models import PlanificationArrivage, PlanificationLivraison
from .serializers import PlanificationArrivageSerializer, PlanificationLivraisonSerializer
from users.permissions import IsCollecteur
from users.models import Role


class PlanificationArrivageViewSet(viewsets.ModelViewSet):
    serializer_class   = PlanificationArrivageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PlanificationArrivage.objects.select_related('echantillon').all()

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update', 'destroy'):
            return [IsCollecteur()]
        return [IsAuthenticated()]


class PlanificationLivraisonViewSet(viewsets.ModelViewSet):
    serializer_class   = PlanificationLivraisonSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PlanificationLivraison.objects.select_related('echantillon').all()

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update', 'destroy'):
            return [IsCollecteur()]
        return [IsAuthenticated()]
