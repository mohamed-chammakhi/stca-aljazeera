from django.db.models.signals import post_save, pre_save, pre_delete
from django.dispatch import receiver
from django.utils import timezone


def _notify_ceos(type, titre, message, echantillon=None, section='ECHANTILLONS'):
    from .models import Notification
    from django.contrib.auth import get_user_model
    User = get_user_model()
    ceos = User.objects.filter(role='direction', is_active=True)
    Notification.objects.bulk_create([
        Notification(
            destinataire=ceo,
            type=type,
            titre=titre,
            message=message,
            echantillon=echantillon,
            section=section,
        )
        for ceo in ceos
    ])


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
def echantillon_post_save(sender, instance, created, **kwargs):
    ref = instance.numero or str(instance.id)[:8]

    if created:
        _notify_ceos(
            type='NOUVEL_ECHANTILLON',
            titre='Nouvel échantillon enregistré',
            message=f"L'échantillon {ref} a été ajouté au système.",
            echantillon=instance,
            section='ECHANTILLONS',
        )
        return

    old_recu = getattr(instance, '_old_recu_physiquement', None)
    old_statut = getattr(instance, '_old_statut_collecteur', None)

    if old_recu is False and instance.recu_physiquement:
        now = timezone.now()
        _notify_ceos(
            type='ECHANTILLON_RECU',
            titre='Échantillon reçu physiquement',
            message=(
                f"L'échantillon {ref} a été marqué comme reçu physiquement "
                f"le {now.strftime('%d/%m/%Y à %H:%M')}."
            ),
            echantillon=instance,
            section='ECHANTILLONS',
        )
    elif old_statut != 'achat_confirme' and instance.statut_collecteur == 'achat_confirme':
        _notify_ceos(
            type='ACHAT_CONFIRME',
            titre='Achat confirmé',
            message=f"L'achat de l'échantillon {ref} a été confirmé par le collecteur.",
            echantillon=instance,
            section='ACHATS',
        )
    else:
        _notify_ceos(
            type='ECHANTILLON_MODIFIE',
            titre='Échantillon modifié',
            message=f"L'échantillon {ref} a été modifié.",
            echantillon=instance,
            section='ECHANTILLONS',
        )


@receiver(pre_delete, sender='echantillons.Echantillon')
def echantillon_pre_delete(sender, instance, **kwargs):
    ref = instance.numero or str(instance.id)[:8]
    _notify_ceos(
        type='ECHANTILLON_SUPPRIME',
        titre='Échantillon supprimé',
        message=f"L'échantillon {ref} a été supprimé du système.",
        echantillon=None,
        section='ECHANTILLONS',
    )


# ── Evaluation signals ─────────────────────────────────────────────────────────

@receiver(post_save, sender='evaluations.EvaluationOrganoleptique')
def evaluation_post_save(sender, instance, **kwargs):
    if instance.statut != 'soumis':
        return

    from django.contrib.auth import get_user_model
    User = get_user_model()

    echantillon = instance.echantillon
    ref = echantillon.numero or str(echantillon.id)[:8]

    submitted_count = sender.objects.filter(echantillon=echantillon, statut='soumis').count()
    total_tasters = User.objects.filter(role='degustateur', is_active=True).count()

    if submitted_count == 1:
        _notify_ceos(
            type='PREMIERE_EVALUATION',
            titre='Première évaluation soumise',
            message=f"Une première évaluation organoleptique a été soumise pour l'échantillon {ref}.",
            echantillon=echantillon,
            section='EVALUATIONS',
        )

    if total_tasters > 0 and submitted_count >= total_tasters:
        _notify_ceos(
            type='TOUTES_EVALUATIONS',
            titre='Toutes les évaluations soumises',
            message=(
                f"Tous les dégustateurs ont soumis leur évaluation pour l'échantillon {ref}. "
                f"Vous pouvez maintenant prendre votre décision d'approbation."
            ),
            echantillon=echantillon,
            section='EVALUATIONS',
        )


# ── Analyse signals ────────────────────────────────────────────────────────────

@receiver(post_save, sender='analyses.AnalyseLabo')
def analyse_post_save(sender, instance, **kwargs):
    if instance.statut != 'soumis':
        return

    echantillon = instance.echantillon
    ref = echantillon.numero if echantillon else '—'
    _notify_ceos(
        type='ANALYSE_SOUMISE',
        titre='Analyse laboratoire soumise',
        message=f"L'analyse laboratoire de l'échantillon {ref} a été soumise par le technicien.",
        echantillon=echantillon,
        section='ANALYSES',
    )
