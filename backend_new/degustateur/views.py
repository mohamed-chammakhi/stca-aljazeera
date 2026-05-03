from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from evaluations.models import EvaluationOrganoleptique
from sessions_degustation.models import SessionDegustation


class DegustateurDelaiView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')

        my_evals = EvaluationOrganoleptique.objects.filter(
            degustateur=request.user, statut='soumis'
        ).select_related('echantillon')
        if date_debut:
            my_evals = my_evals.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            my_evals = my_evals.filter(soumis_le__date__lte=date_fin)

        my_delays = []
        points = []
        for ev in my_evals:
            if ev.echantillon.date_arrivee_echantillon:
                d = (ev.soumis_le - ev.echantillon.date_arrivee_echantillon).days
                my_delays.append(d)
                points.append({'date': ev.soumis_le.date().isoformat(), 'delai': d})

        all_evals = EvaluationOrganoleptique.objects.filter(statut='soumis').select_related('echantillon')
        if date_debut:
            all_evals = all_evals.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            all_evals = all_evals.filter(soumis_le__date__lte=date_fin)

        all_delays = [
            (ev.soumis_le - ev.echantillon.date_arrivee_echantillon).days
            for ev in all_evals if ev.echantillon.date_arrivee_echantillon
        ]

        return Response({
            'mon_delai_moyen': round(sum(my_delays) / len(my_delays), 1) if my_delays else 0,
            'panel_moyen': round(sum(all_delays) / len(all_delays), 1) if all_delays else 0,
            'nb_evals': len(my_delays),
            'points': points,
        })


class DegustateurActiviteView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        offset = int(request.query_params.get('offset', 0))
        limit = int(request.query_params.get('limit', 5))
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')

        evals = EvaluationOrganoleptique.objects.filter(
            degustateur=request.user
        ).select_related('echantillon')
        if date_debut:
            evals = evals.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            evals = evals.filter(soumis_le__date__lte=date_fin)

        activities = [{
            'type': 'evaluation',
            'date': ev.soumis_le.isoformat(),
            'description': f"Évaluation — {ev.echantillon.numero} ({ev.statut})",
        } for ev in evals]

        activities.sort(key=lambda x: x['date'], reverse=True)
        total = len(activities)
        return Response({'count': total, 'results': activities[offset:offset + limit]})
