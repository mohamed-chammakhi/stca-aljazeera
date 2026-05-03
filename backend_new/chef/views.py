from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count, Q
from django.utils import timezone
from datetime import timedelta
from echantillons.models import Echantillon
from evaluations.models import EvaluationOrganoleptique
from sessions_degustation.models import SessionDegustation


class ChefEvaluationsView(APIView):
    """All evaluations grouped by sample, with divergence flag if >=3 submitted and any score deviates >1.5 from panel avg."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')
        search = request.query_params.get('search', '')

        qs = EvaluationOrganoleptique.objects.select_related('echantillon', 'degustateur')
        if date_debut:
            qs = qs.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            qs = qs.filter(soumis_le__date__lte=date_fin)
        if search:
            qs = qs.filter(
                Q(echantillon__numero__icontains=search) |
                Q(echantillon__variete__icontains=search)
            )

        grouped = {}
        for ev in qs:
            eid = str(ev.echantillon_id)
            if eid not in grouped:
                grouped[eid] = {
                    'echantillon_id': eid,
                    'echantillon_numero': ev.echantillon.numero,
                    'variete': ev.echantillon.variete,
                    'evaluations': [],
                    'divergence': False,
                }
            grouped[eid]['evaluations'].append({
                'id': str(ev.id),
                'degustateur': f"{ev.degustateur.prenom} {ev.degustateur.nom}" if ev.degustateur else '',
                'fruite': float(ev.fruite) if ev.fruite is not None else None,
                'amertume': float(ev.amertume) if ev.amertume is not None else None,
                'piquant': float(ev.piquant) if ev.piquant is not None else None,
                'classification': ev.classification,
                'statut': ev.statut,
            })

        for group in grouped.values():
            submitted = [e for e in group['evaluations'] if e['statut'] == 'soumis']
            if len(submitted) >= 3:
                for attr in ('fruite', 'amertume', 'piquant'):
                    vals = [e[attr] for e in submitted if e[attr] is not None]
                    if len(vals) >= 3:
                        avg = sum(vals) / len(vals)
                        if any(abs(v - avg) > 1.5 for v in vals):
                            group['divergence'] = True
                            break

        return Response(list(grouped.values()))


class ChefDashboardPipelineView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            'receptionne': Echantillon.objects.filter(statut_collecteur='receptionne', recu_physiquement=False).count(),
            'en_attente_eval': Echantillon.objects.filter(recu_physiquement=True, statut_degustateur='non_evaluee').count(),
            'en_cours': Echantillon.objects.filter(statut_degustateur='en_cours').count(),
            'soumis': Echantillon.objects.filter(statut_degustateur='soumis').count(),
        })


class ChefDashboardUrgentesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        now = timezone.now()
        echantillons = Echantillon.objects.filter(
            recu_physiquement=True,
            statut_degustateur__in=['non_evaluee', 'en_cours']
        ).order_by('date_arrivee_echantillon')[:20]

        result = []
        for e in echantillons:
            days = (now - e.date_arrivee_echantillon).days if e.date_arrivee_echantillon else 0
            result.append({
                'id': str(e.id),
                'numero': e.numero,
                'variete': e.variete,
                'days_waiting': days,
                'badge': 'red' if days >= 2 else ('amber' if days == 1 else 'normal'),
            })
        return Response(result)


class ChefDashboardSessionsEnAttenteView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        sessions = SessionDegustation.objects.filter(
            statut='en_attente_validation'
        ).select_related('cree_par').order_by('date')
        return Response([{
            'id': str(s.id),
            'titre': s.titre,
            'date': s.date.isoformat(),
            'heure': s.heure.isoformat() if s.heure else None,
            'lieu': s.lieu,
            'cree_par': f"{s.cree_par.prenom} {s.cree_par.nom}" if s.cree_par else '',
        } for s in sessions])


class ChefDashboardDelaiView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')

        qs = EvaluationOrganoleptique.objects.filter(statut='soumis').select_related('degustateur', 'echantillon')
        if date_debut:
            qs = qs.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            qs = qs.filter(soumis_le__date__lte=date_fin)

        per_member = {}
        all_delays = []
        for ev in qs:
            if not ev.echantillon.date_arrivee_echantillon:
                continue
            delay = (ev.soumis_le - ev.echantillon.date_arrivee_echantillon).days
            all_delays.append(delay)
            uid = str(ev.degustateur_id) if ev.degustateur_id else 'inconnu'
            if uid not in per_member:
                per_member[uid] = {
                    'nom': f"{ev.degustateur.prenom} {ev.degustateur.nom}" if ev.degustateur else 'Inconnu',
                    'delays': [],
                }
            per_member[uid]['delays'].append(delay)

        panel_moyen = round(sum(all_delays) / len(all_delays), 1) if all_delays else 0
        membres = [{
            'nom': v['nom'],
            'delai_moyen': round(sum(v['delays']) / len(v['delays']), 1),
            'panel_moyen': panel_moyen,
        } for v in per_member.values()]

        return Response({'membres': membres, 'panel_moyen': panel_moyen})


class ChefDashboardAlignementView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')

        qs = EvaluationOrganoleptique.objects.filter(statut='soumis').select_related('degustateur')
        if date_debut:
            qs = qs.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            qs = qs.filter(soumis_le__date__lte=date_fin)

        by_sample = {}
        for ev in qs:
            eid = str(ev.echantillon_id)
            if eid not in by_sample:
                by_sample[eid] = []
            by_sample[eid].append(ev)

        member_data = {}
        for evals in by_sample.values():
            if len(evals) < 2:
                continue
            scores = [float(e.fruite or 0) for e in evals]
            avg = sum(scores) / len(scores)
            for ev in evals:
                uid = str(ev.degustateur_id) if ev.degustateur_id else 'inconnu'
                if uid not in member_data:
                    member_data[uid] = {
                        'nom': f"{ev.degustateur.prenom} {ev.degustateur.nom}" if ev.degustateur else 'Inconnu',
                        'divergent': 0, 'total': 0,
                    }
                member_data[uid]['divergent'] += 1 if abs(float(ev.fruite or 0) - avg) > 1.5 else 0
                member_data[uid]['total'] += 1

        membres = [{
            'nom': v['nom'],
            'divergence_pct': round(100 * v['divergent'] / v['total'], 1) if v['total'] else 0,
        } for v in member_data.values()]

        return Response({'membres': membres})


class ChefDashboardClassificationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')

        qs = EvaluationOrganoleptique.objects.filter(statut='soumis')
        if date_debut:
            qs = qs.filter(soumis_le__date__gte=date_debut)
        if date_fin:
            qs = qs.filter(soumis_le__date__lte=date_fin)

        from collections import defaultdict
        monthly = defaultdict(lambda: {'extra_vierge': 0, 'vierge': 0, 'lampante': 0})
        for ev in qs:
            label = ev.soumis_le.strftime('%b %Y')
            if ev.classification == 'extra_vierge':
                monthly[label]['extra_vierge'] += 1
            elif ev.classification in ('vierge', 'vierge_ordinaire'):
                monthly[label]['vierge'] += 1
            elif ev.classification == 'lampante':
                monthly[label]['lampante'] += 1

        return Response([{'label': k, **v} for k, v in sorted(monthly.items())])


class ChefDashboardPresenceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_debut = request.query_params.get('date_debut')
        date_fin = request.query_params.get('date_fin')
        today = timezone.now().date()

        qs = SessionDegustation.objects.filter(participants=request.user)
        if date_debut:
            qs = qs.filter(date__gte=date_debut)
        if date_fin:
            qs = qs.filter(date__lte=date_fin)

        present = qs.filter(statut='terminee').count()
        manquee = qs.filter(statut='planifiee', date__lt=today).count()

        prochaine = SessionDegustation.objects.filter(
            participants=request.user,
            date__gte=today,
            statut='planifiee'
        ).order_by('date').first()

        countdown = f"{(prochaine.date - today).days}j" if prochaine else None

        return Response({
            'present': present,
            'manquee': manquee,
            'prochaine_titre': prochaine.titre if prochaine else None,
            'prochaine_date': prochaine.date.isoformat() if prochaine else None,
            'prochaine_lieu': prochaine.lieu if prochaine else None,
            'prochaine_countdown': countdown,
        })


class ChefDashboardUrgentesCeoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        echantillons = Echantillon.objects.filter(
            statut_degustateur='soumis',
            statut_ceo='selectionne'
        ).select_related('collecteur', 'fournisseur')[:20]

        return Response([{
            'id': str(e.id),
            'numero': e.numero,
            'variete': e.variete,
            'collecteur_nom': f"{e.collecteur.prenom} {e.collecteur.nom}" if e.collecteur else '',
            'fournisseur_nom': e.fournisseur.nom if e.fournisseur else '',
        } for e in echantillons])


class ChefDashboardActiviteView(APIView):
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

        sessions = SessionDegustation.objects.filter(cree_par=request.user)
        if date_debut:
            sessions = sessions.filter(date_creation__date__gte=date_debut)
        if date_fin:
            sessions = sessions.filter(date_creation__date__lte=date_fin)
        for s in sessions:
            activities.append({
                'type': 'session',
                'date': s.date_creation.isoformat(),
                'description': f"Session créée — {s.titre}",
            })

        activities.sort(key=lambda x: x['date'], reverse=True)
        total = len(activities)
        page = activities[offset:offset + limit]
        return Response({'count': total, 'results': page})
