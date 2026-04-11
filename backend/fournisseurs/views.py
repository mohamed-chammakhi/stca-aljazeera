from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter

from .models import Fournisseur
from .serializers import FournisseurSerializer
from users.permissions import IsDirection


class FournisseurViewSet(viewsets.ModelViewSet):
    """
    GET    /api/fournisseurs/         — all authenticated users
    POST   /api/fournisseurs/         — Direction only
    PATCH  /api/fournisseurs/<id>/    — Direction only
    DELETE /api/fournisseurs/<id>/    — Direction only
    """
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    filter_backends  = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    search_fields    = ['nom', 'code_fournisseur', 'region']
    ordering_fields  = ['nom', 'code_fournisseur']

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update', 'destroy'):
            return [IsDirection()]
        return [IsAuthenticated()]
