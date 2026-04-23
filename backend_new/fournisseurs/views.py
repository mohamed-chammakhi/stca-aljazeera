from rest_framework import generics
from .models import Fournisseur
from .serializers import FournisseurSerializer
from rest_framework.permissions import IsAuthenticated
class FournisseurListCreateView(generics.ListCreateAPIView):
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    permission_classes = [IsAuthenticated]
class FournisseurDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    permission_classes = [IsAuthenticated]
