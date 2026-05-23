from rest_framework import generics
from rest_framework.filters import OrderingFilter, SearchFilter

from users.permissions import IsChefPanel, IsCollecteur, IsDegustateur, IsDirection

from .models import Fournisseur
from .serializers import FournisseurSerializer


class FournisseurListCreateView(generics.ListCreateAPIView):
    queryset = Fournisseur.objects.all().order_by('nom')
    serializer_class = FournisseurSerializer
    permission_classes = [IsCollecteur | IsDirection | IsDegustateur | IsChefPanel]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['nom', 'code_fournisseur', 'region', 'telephone']
    ordering_fields = ['nom', 'date_creation', 'code_fournisseur']

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsCollecteur()]
        return super().get_permissions()


class FournisseurDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    permission_classes = [IsCollecteur | IsDirection | IsDegustateur | IsChefPanel]

    def get_permissions(self):
        if self.request.method in ('PUT', 'PATCH', 'DELETE'):
            return [IsCollecteur()]
        return super().get_permissions()
