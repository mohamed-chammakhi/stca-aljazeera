from rest_framework import generics, status
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Echantillon
from .serializers import EchantillonSerializer
from .filters import EchantillonFilter


class EchantillonListCreateView(generics.ListCreateAPIView):
    serializer_class = EchantillonSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = EchantillonFilter
    search_fields = ['numero', 'reference_bouteille', 'variete', 'fournisseur__nom', 'fournisseur__code_fournisseur']
    ordering_fields = ['date_ajout', 'updated_at', 'statut_collecteur']
    ordering = ['-date_ajout']

    def get_queryset(self):
        return Echantillon.objects.all().order_by('-date_ajout')


class EchantillonDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Echantillon.objects.all()
    serializer_class = EchantillonSerializer
    permission_classes = [IsAuthenticated]
 # Block deletion if sample has been physically received
    def destroy(self, request, *args, **kwargs):
        echantillon = self.get_object()
        if echantillon.recu_physiquement:
            return Response(
                {"detail": "Impossible de supprimer un échantillon déjà reçu physiquement."},
                status=status.HTTP_403_FORBIDDEN
            )
        return super().destroy(request, *args, **kwargs)