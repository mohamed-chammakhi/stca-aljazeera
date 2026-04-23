from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import EvaluationOrganoleptique
from .serializers import EvaluationSerializer


class EvaluationListCreateView(generics.ListCreateAPIView):
    serializer_class = EvaluationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return EvaluationOrganoleptique.objects.filter(
            degustateur=self.request.user
        )

    def perform_create(self, serializer):
        serializer.save(degustateur=self.request.user)


class EvaluationDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = EvaluationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return EvaluationOrganoleptique.objects.filter(
            degustateur=self.request.user
        )
