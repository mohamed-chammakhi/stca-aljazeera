from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import PlanificationArrivage, PlanificationLivraison
from .serializers import PlanificationArrivageSerializer, PlanificationLivraisonSerializer


class ArrivageListCreateView(generics.ListCreateAPIView):
    serializer_class = PlanificationArrivageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PlanificationArrivage.objects.all()


class ArrivageDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = PlanificationArrivage.objects.all()
    serializer_class = PlanificationArrivageSerializer
    permission_classes = [IsAuthenticated]


class LivraisonListCreateView(generics.ListCreateAPIView):
    serializer_class = PlanificationLivraisonSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PlanificationLivraison.objects.all().order_by('-date_creation')


class LivraisonDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = PlanificationLivraison.objects.all()
    serializer_class = PlanificationLivraisonSerializer
    permission_classes = [IsAuthenticated]
