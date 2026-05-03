from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
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


class EvaluationSoumettreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        # Fetch the evaluation belonging to this degustateur
        try:
            evaluation = EvaluationOrganoleptique.objects.get(pk=pk, degustateur=request.user)
        except EvaluationOrganoleptique.DoesNotExist:
            return Response({'detail': 'Évaluation non trouvée.'}, status=status.HTTP_404_NOT_FOUND)

        # Guard: already submitted
        if evaluation.statut == 'soumis':
            return Response({'detail': 'Évaluation déjà soumise.'}, status=status.HTTP_400_BAD_REQUEST)

        # Submit this evaluation
        evaluation.statut = 'soumis'
        evaluation.save()

        # Update the linked echantillon's statut_degustateur
        echantillon = evaluation.echantillon
        still_in_progress = EvaluationOrganoleptique.objects.filter(
            echantillon=echantillon,
            statut='en_cours',
        ).exclude(pk=evaluation.pk).exists()

        if still_in_progress:
            echantillon.statut_degustateur = 'en_cours'
        else:
            echantillon.statut_degustateur = 'soumis'
        echantillon.save()

        return Response(EvaluationSerializer(evaluation, context={'request': request}).data, status=status.HTTP_200_OK)
