from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import EvaluationOrganoleptique
from .serializers import EvaluationSerializer
from echantillons.models import Echantillon


class EvaluationListCreateView(generics.ListCreateAPIView):
    serializer_class = EvaluationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return EvaluationOrganoleptique.objects.select_related(
            'echantillon', 'degustateur', 'session'
        ).filter(degustateur=self.request.user)

    def perform_create(self, serializer):
        serializer.save(degustateur=self.request.user)


class EvaluationDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = EvaluationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return EvaluationOrganoleptique.objects.select_related(
            'echantillon', 'degustateur', 'session'
        ).filter(degustateur=self.request.user)


class EvaluationSoumettreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        with transaction.atomic():
            try:
                evaluation = EvaluationOrganoleptique.objects.select_for_update().get(
                    pk=pk, degustateur=request.user
                )
            except EvaluationOrganoleptique.DoesNotExist:
                return Response({'detail': 'Évaluation introuvable.'}, status=status.HTTP_404_NOT_FOUND)
            if evaluation.statut == 'soumis':
                return Response({'detail': 'Évaluation déjà soumise.'}, status=status.HTTP_400_BAD_REQUEST)
            evaluation.statut = 'soumis'
            evaluation.soumis_le = timezone.now()
            evaluation.save()
            echantillon = Echantillon.objects.select_for_update().get(pk=evaluation.echantillon_id)
            still_in_progress = EvaluationOrganoleptique.objects.filter(
                echantillon=echantillon, statut='en_cours'
            ).exclude(pk=evaluation.pk).exists()
            echantillon.statut_degustateur = 'en_cours' if still_in_progress else 'soumis'
            echantillon.save()
        return Response(EvaluationSerializer(evaluation).data)
