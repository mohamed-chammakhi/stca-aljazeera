from django.utils import timezone
from rest_framework.response import Response
from rest_framework.views import APIView

from core.dashboard_calculations import (
    evaluation_delays,
    monthly_classification_distribution,
    pipeline_counts,
    presence_summary,
    rounded_average,
    sessions_for_user,
    urgent_evaluations_payload,
)
from echantillons.models import Echantillon
from evaluations.models import EvaluationOrganoleptique
from users.permissions import IsDegustateur


def _filter_submitted_evaluations(queryset, date_debut, date_fin):
    queryset = queryset.filter(
        statut=EvaluationOrganoleptique.Statut.SOUMIS,
        soumis_le__isnull=False,
    )
    if date_debut:
        queryset = queryset.filter(soumis_le__date__gte=date_debut)
    if date_fin:
        queryset = queryset.filter(soumis_le__date__lte=date_fin)
    return queryset


class DegustateurPipelineView(APIView):
    permission_classes = [IsDegustateur]

    def get(self, request):
        return Response(pipeline_counts())


class DegustateurUrgentesView(APIView):
    permission_classes = [IsDegustateur]

    def get(self, request):
        echantillons = Echantillon.objects.filter(
            recu_physiquement=True,
            statut_degustateur__in=(
                Echantillon.StatutDegustateur.NON_EVALUEE,
                Echantillon.StatutDegustateur.EN_COURS,
            ),
        ).select_related('collecteur', 'fournisseur').order_by(
            'date_arrivee_echantillon'
        )[:20]
        return Response(urgent_evaluations_payload(echantillons, timezone.now()))


class DegustateurClassificationsView(APIView):
    permission_classes = [IsDegustateur]

    def get(self, request):
        evaluations = _filter_submitted_evaluations(
            EvaluationOrganoleptique.objects.all(),
            request.query_params.get('date_debut'),
            request.query_params.get('date_fin'),
        ).order_by('soumis_le')[:1000]
        return Response(monthly_classification_distribution(evaluations))


class DegustateurPresenceView(APIView):
    permission_classes = [IsDegustateur]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')
        sessions = sessions_for_user(request.user)
        if date_debut:
            sessions = sessions.filter(date__gte=date_debut)
        if date_fin:
            sessions = sessions.filter(date__lte=date_fin)
        return Response(
            presence_summary(sessions, request.user, timezone.now().date())
        )


class DegustateurDelaiView(APIView):
    permission_classes = [IsDegustateur]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')
        own_evaluations = _filter_submitted_evaluations(
            EvaluationOrganoleptique.objects.filter(degustateur=request.user),
            date_debut,
            date_fin,
        ).select_related('echantillon').order_by('soumis_le')
        panel_evaluations = _filter_submitted_evaluations(
            EvaluationOrganoleptique.objects.all(),
            date_debut,
            date_fin,
        ).select_related('echantillon')

        own_delays = evaluation_delays(own_evaluations)
        panel_delays = evaluation_delays(panel_evaluations)
        return Response({
            'mon_delai_moyen': rounded_average(
                [delay for _, delay in own_delays]
            ),
            'panel_moyen': rounded_average(
                [delay for _, delay in panel_delays]
            ),
            'nb_evals': len(own_delays),
            'points': [
                {
                    'date': evaluation.soumis_le.date().isoformat(),
                    'delai': delay,
                }
                for evaluation, delay in own_delays
            ],
        })


class DegustateurActiviteView(APIView):
    permission_classes = [IsDegustateur]

    def get(self, request):
        offset = int(request.query_params.get('offset', 0))
        limit = min(int(request.query_params.get('limit', 5)), 100)
        evaluations = _filter_submitted_evaluations(
            EvaluationOrganoleptique.objects.filter(degustateur=request.user),
            request.query_params.get('date_debut'),
            request.query_params.get('date_fin'),
        ).select_related('echantillon').order_by('-soumis_le')
        total = evaluations.count()
        evaluations = evaluations[offset:offset + limit]
        activities = [
            {
                'id': str(evaluation.id),
                'type': 'evaluation',
                'date': evaluation.soumis_le.isoformat(),
                'horodatage': evaluation.soumis_le.isoformat(),
                'description': (
                    f'Évaluation — {evaluation.echantillon.numero} '
                    f'({evaluation.statut})'
                ),
                'action': (
                    f'Évaluation — {evaluation.echantillon.numero} '
                    f'({evaluation.statut})'
                ),
            }
            for evaluation in evaluations
        ]
        return Response({'count': total, 'results': activities})
