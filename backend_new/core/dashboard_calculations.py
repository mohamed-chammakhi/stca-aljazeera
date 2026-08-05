from collections import defaultdict

from django.db.models import Q

from echantillons.models import Echantillon


def user_full_name(user):
    if not user:
        return ''
    return f'{user.prenom} {user.nom}'.strip()


def rounded_average(values):
    return round(sum(values) / len(values), 1) if values else 0


def evaluation_delays(evaluations):
    """Return (evaluation, fractional days) for evaluations with usable dates."""
    result = []
    for evaluation in evaluations:
        received_at = evaluation.echantillon.date_arrivee_echantillon
        if not received_at or not evaluation.soumis_le:
            continue
        delay = (evaluation.soumis_le - received_at).total_seconds() / 86400
        result.append((evaluation, delay))
    return result


def pipeline_counts():
    """Global, non-nominative operational counts shared by both dashboards."""
    return {
        'receptionne': Echantillon.objects.filter(
            statut_collecteur=Echantillon.StatutCollecteur.RECEPTIONNE,
            recu_physiquement=False,
        ).count(),
        'non_evaluee': Echantillon.objects.filter(
            recu_physiquement=True,
            statut_degustateur=Echantillon.StatutDegustateur.NON_EVALUEE,
        ).count(),
        'en_cours': Echantillon.objects.filter(
            statut_degustateur=Echantillon.StatutDegustateur.EN_COURS,
        ).count(),
        'soumise': Echantillon.objects.filter(
            statut_degustateur=Echantillon.StatutDegustateur.SOUMIS,
        ).count(),
    }


def urgent_evaluations_payload(echantillons, now):
    """Serialize global work-to-do samples without exposing evaluator identities."""
    result = []
    for echantillon in echantillons:
        days = (
            (now - echantillon.date_arrivee_echantillon).days
            if echantillon.date_arrivee_echantillon
            else 0
        )
        result.append({
            'id': str(echantillon.id),
            'numero': echantillon.numero,
            'reference': f'{echantillon.variete} - {echantillon.numero}'.strip(' -'),
            'variete': echantillon.variete,
            'collecteur_nom': user_full_name(echantillon.collecteur),
            'fournisseur_nom': echantillon.fournisseur.nom if echantillon.fournisseur else '',
            'jours_en_attente': days,
            'days_waiting': days,
            'badge': 'red' if days >= 2 else ('amber' if days == 1 else 'normal'),
        })
    return result


def monthly_classification_distribution(evaluations):
    """Aggregate classifications by month; never emits an evaluator identity."""
    monthly = defaultdict(lambda: {
        'extra_vierge': 0,
        'vierge': 0,
        'lampante': 0,
    })
    for evaluation in evaluations:
        label = evaluation.soumis_le.strftime('%b %Y')
        if evaluation.classification == Echantillon.Classification.EXTRA_VIERGE:
            monthly[label]['extra_vierge'] += 1
        elif evaluation.classification in (
            Echantillon.Classification.VIERGE,
            Echantillon.Classification.VIERGE_ORDINAIRE,
        ):
            monthly[label]['vierge'] += 1
        elif evaluation.classification == Echantillon.Classification.LAMPANTE:
            monthly[label]['lampante'] += 1
    return [{'label': label, **counts} for label, counts in sorted(monthly.items())]


def presence_summary(sessions, user, today):
    """Aggregate only the supplied user's attendance over an already scoped queryset."""
    present = sessions.filter(presences_confirmees=user).count()
    missed = (
        sessions.filter(date__lt=today)
        .exclude(statut='refusee')
        .exclude(presences_confirmees=user)
        .count()
    )
    upcoming = (
        sessions.filter(date__gte=today, statut='planifiee')
        .order_by('date')
        .first()
    )
    return {
        'present': present,
        'manquee': missed,
        'prochaine_titre': upcoming.titre if upcoming else None,
        'prochaine_date': upcoming.date.isoformat() if upcoming else None,
        'prochaine_lieu': upcoming.lieu if upcoming else None,
        'prochaine_countdown': f'{(upcoming.date - today).days}j' if upcoming else None,
    }


def sessions_for_user(user):
    """Scope sessions before attendance aggregation to prevent cross-user leakage."""
    from sessions_degustation.models import SessionDegustation

    return SessionDegustation.objects.filter(
        Q(participants=user) | Q(cree_par=user)
    ).distinct()
