from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Echantillon
from .serializers import EchantillonSerializer


class EchantillonListCreateView(generics.ListCreateAPIView):
    serializer_class = EchantillonSerializer
    permission_classes = [IsAuthenticated]

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