from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from echantillons.models import Echantillon
from users.models import User
from users.permissions import IsDegustateurOrChef, IsDirection

from .models import EvaluationOrganoleptique
from .serializers import EvaluationSerializer


class EvaluationListCreateView(generics.ListCreateAPIView):
    serializer_class = EvaluationSerializer
    permission_classes = [IsDegustateurOrChef | IsDirection]

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsDegustateurOrChef()]
        return super().get_permissions()

    def get_queryset(self):
        qs = EvaluationOrganoleptique.objects.select_related(
            'echantillon', 'degustateur', 'session'
        )
        if self.request.user.role != User.Role.DIRECTION:
            qs = qs.filter(degustateur=self.request.user)
        echantillon_id = self.request.query_params.get('echantillon')
        if echantillon_id:
            qs = qs.filter(echantillon_id=echantillon_id)
        return qs.order_by('-date_modification')

    def perform_create(self, serializer):
        evaluation = serializer.save(degustateur=self.request.user)
        echantillon = evaluation.echantillon
        if echantillon.statut_degustateur == Echantillon.StatutDegustateur.NON_EVALUEE:
            echantillon.statut_degustateur = Echantillon.StatutDegustateur.EN_COURS
            echantillon.save(update_fields=['statut_degustateur', 'updated_at'])


class EvaluationDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = EvaluationSerializer
    permission_classes = [IsDegustateurOrChef]

    def get_queryset(self):
        return EvaluationOrganoleptique.objects.select_related(
            'echantillon', 'degustateur', 'session'
        ).filter(degustateur=self.request.user)

    def perform_update(self, serializer):
        if serializer.instance.statut == EvaluationOrganoleptique.Statut.SOUMIS:
            raise ValidationError({'detail': 'Evaluation deja soumise et verrouillee.'})
        serializer.save()

    def perform_destroy(self, instance):
        if instance.statut == EvaluationOrganoleptique.Statut.SOUMIS:
            raise PermissionDenied('Evaluation deja soumise et verrouillee.')
        instance.delete()


class EvaluationSoumettreView(APIView):
    permission_classes = [IsDegustateurOrChef]

    def post(self, request, pk):
        with transaction.atomic():
            try:
                evaluation = EvaluationOrganoleptique.objects.select_for_update().get(
                    pk=pk, degustateur=request.user
                )
            except EvaluationOrganoleptique.DoesNotExist:
                return Response(
                    {'detail': 'Evaluation introuvable.'},
                    status=status.HTTP_404_NOT_FOUND,
                )
            if evaluation.statut == EvaluationOrganoleptique.Statut.SOUMIS:
                return Response(
                    {'detail': 'Evaluation deja soumise.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            evaluation.statut = EvaluationOrganoleptique.Statut.SOUMIS
            evaluation.soumis_le = timezone.now()
            evaluation.save()

            echantillon = Echantillon.objects.select_for_update().get(
                pk=evaluation.echantillon_id
            )
            active_taster_count = User.objects.filter(
                is_active=True,
                role__in=[User.Role.DEGUSTATEUR, User.Role.CHEF_DEGUSTATION],
            ).count()
            submitted_count = EvaluationOrganoleptique.objects.filter(
                echantillon=echantillon,
                statut=EvaluationOrganoleptique.Statut.SOUMIS,
            ).values('degustateur').distinct().count()
            echantillon.statut_degustateur = (
                Echantillon.StatutDegustateur.SOUMIS
                if active_taster_count and submitted_count >= active_taster_count
                else Echantillon.StatutDegustateur.EN_COURS
            )
            echantillon.save(update_fields=['statut_degustateur', 'updated_at'])

        return Response(EvaluationSerializer(evaluation).data)
