from rest_framework import generics
from rest_framework.filters import OrderingFilter, SearchFilter

from users.permissions import IsChefDegustation, IsCollecteur, IsDegustateur, IsDirection
from users.models import User

from .models import Fournisseur
from .serializers import FournisseurSerializer


class FournisseurListCreateView(generics.ListCreateAPIView):
    queryset = Fournisseur.objects.all().order_by('nom')
    serializer_class = FournisseurSerializer
    permission_classes = [IsCollecteur | IsDirection | IsDegustateur | IsChefDegustation]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['nom', 'code_fournisseur', 'region', 'telephone']
    ordering_fields = ['nom', 'date_creation', 'code_fournisseur']

    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.COLLECTEUR:
            return (
                Fournisseur.objects
                .filter(echantillons__collecteur=user)
                .distinct()
                .order_by('nom')
            )
        return Fournisseur.objects.all().order_by('nom')

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsCollecteur()]
        return super().get_permissions()


class FournisseurDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    permission_classes = [IsCollecteur | IsDirection | IsDegustateur | IsChefDegustation]

    def get_queryset(self):
        user = self.request.user
        if user.role == User.Role.COLLECTEUR:
            return (
                Fournisseur.objects
                .filter(echantillons__collecteur=user)
                .distinct()
            )
        return Fournisseur.objects.all()

    def get_permissions(self):
        if self.request.method in ('PUT', 'PATCH', 'DELETE'):
            return [IsCollecteur()]
        return super().get_permissions()
