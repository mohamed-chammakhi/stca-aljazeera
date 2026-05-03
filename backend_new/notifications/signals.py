from django.db.models.signals import post_save, pre_save, pre_delete
from django.dispatch import receiver
from django.utils import timezone
from .models import Notification
from users.models import User


def _get_users_by_roles(*roles):
    return User.objects.filter(role__in=roles, is_active=True)


def _notify(recipients, type_, titre, message, echantillon=None, section='ECHANTILLONS'):
    for user in recipients:
        Notification.objects.create(
            destinataire=user,
            type=type_,
            titre=titre,
            message=message,
            echantillon=echantillon,
            section=section,
        )


# ── Echantillon signals ────────────────────────────────────────────────────────

@receiver(pre_save, sender='echantillons.Echantillon')
def echantillon_pre_save(sender, instance, **kwargs):
    """Store old field values so post_save can detect what changed."""
    if instance.pk:
        try:
            old = sender.objects.get(pk=instance.pk)
            instance._old_recu_physiquement = old.recu_physiquement
            instance._old_statut_collecteur = old.statut_collecteur
        except sender.DoesNotExist:
            instance._old_recu_physiquement = False
            instance._old_statut_collecteur = None
    else:
        instance._old_recu_physiquement = False
        instance._old_statut_collecteur = None


@receiver(post_save, sender='echantillons.Echantillon')
def on_echantillon_saved(sender, instance, created, **kwargs):
    ref = instance.numero or str(instance.id)[:8]

    if created:
        recipients = _get_users_by_roles('direction', 'chef_panel', 'degustateur')
        _notify(recipients, 'NOUVEL_ECHANTILLON',
                'Nouvel échantillon',
                f"L'échantillon {ref} a été enregistré.",
                echantillon=instance,
                section='ECHANTILLONS')
        return

    old_recu = getattr(instance, '_old_recu_physiquement', None)
    old_statut = getattr(instance, '_old_statut_collecteur', None)

    if old_recu is False and instance.recu_physiquement:
        now = timezone.now()
        recipients = _get_users_by_roles('direction', 'chef_panel')
        _notify(recipients, 'ECHANTILLON_RECU',
                'Échantillon reçu physiquement',
                (
                    f"L'échantillon {ref} a été marqué comme reçu physiquement "
                    f"le {now.strftime('%d/%m/%Y à %H:%M')}."
                ),
                echantillon=instance,
                section='ECHANTILLONS')
    elif old_statut != 'achat_confirme' and instance.statut_collecteur == 'achat_confirme':
        recipients = _get_users_by_roles('direction', 'chef_panel')
        _notify(recipients, 'ACHAT_CONFIRME',
                'Achat confirmé',
                f"L'achat de {ref} a été confirmé.",
                echantillon=instance,
                section='ACHATS')
    else:
        recipients = _get_users_by_roles('direction', 'chef_panel')
        _notify(recipients, 'ECHANTILLON_MODIFIE',
                'Échantillon modifié',
                f"L'échantillon {ref} a été modifié.",
                echantillon=instance,
                section='ECHANTILLONS')


@receiver(pre_delete, sender='echantillons.Echantillon')
def on_echantillon_deleted(sender, instance, **kwargs):
    ref = instance.numero or str(instance.id)[:8]
    recipients = _get_users_by_roles('direction', 'chef_panel')
    _notify(recipients, 'ECHANTILLON_SUPPRIME',
            'Échantillon supprimé',
            f"L'échantillon {ref} a été supprimé.",
            echantillon=None,
            section='ECHANTILLONS')


# ── Evaluation signals ─────────────────────────────────────────────────────────

@receiver(post_save, sender='evaluations.EvaluationOrganoleptique')
def on_evaluation_saved(sender, instance, created, **kwargs):
    if instance.statut != 'soumis':
        return

    echantillon = instance.echantillon
    ref = echantillon.numero or str(echantillon.id)[:8]

    all_submitted = not sender.objects.filter(
        echantillon=echantillon, statut='en_cours'
    ).exists()

    if all_submitted:
        recipients = _get_users_by_roles('direction', 'chef_panel')
        _notify(recipients, 'TOUTES_EVALUATIONS',
                'Toutes les évaluations soumises',
                f"Toutes les évaluations de {ref} sont soumises.",
                echantillon=echantillon,
                section='EVALUATIONS')
    else:
        recipients = _get_users_by_roles('chef_panel')
        _notify(recipients, 'PREMIERE_EVALUATION',
                'Évaluation soumise',
                f"Une évaluation de {ref} a été soumise.",
                echantillon=echantillon,
                section='EVALUATIONS')


# ── Analyse signals ────────────────────────────────────────────────────────────

@receiver(post_save, sender='analyses.AnalyseLabo')
def on_analyse_saved(sender, instance, created, **kwargs):
    if instance.statut != 'soumis':
        return

    echantillon = instance.echantillon
    ref = echantillon.numero if echantillon else '—'
    recipients = _get_users_by_roles('direction', 'chef_panel')
    _notify(recipients, 'ANALYSE_SOUMISE',
            'Analyse soumise',
            f"L'analyse de {ref} a été soumise.",
            echantillon=echantillon,
            section='ANALYSES')
