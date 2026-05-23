from django.db.models.signals import post_save, pre_delete, pre_save
from django.dispatch import receiver
from django.utils import timezone

from users.models import User

from .models import Notification


def _get_users_by_roles(*roles):
    return User.objects.filter(role__in=roles, is_active=True)


def _notify(recipients, type_, titre, message, echantillon=None, section='ECHANTILLONS'):
    notifications = [
        Notification(
            destinataire=user,
            type=type_,
            titre=titre,
            message=message,
            echantillon=echantillon,
            section=section,
        )
        for user in recipients
    ]
    if notifications:
        Notification.objects.bulk_create(notifications)


def _sample_ref(echantillon):
    if not echantillon:
        return '-'
    return echantillon.numero or echantillon.reference_bouteille or str(echantillon.id)[:8]


@receiver(pre_save, sender='echantillons.Echantillon')
def echantillon_pre_save(sender, instance, **kwargs):
    if instance.pk:
        try:
            old = sender.objects.get(pk=instance.pk)
            instance._old_recu_physiquement = old.recu_physiquement
            instance._old_statut_collecteur = old.statut_collecteur
            instance._old_statut_labo = old.statut_labo
            instance._old_statut_ceo = old.statut_ceo
            instance._old_variete = old.variete
        except sender.DoesNotExist:
            instance._old_recu_physiquement = False
            instance._old_statut_collecteur = None
            instance._old_statut_labo = None
            instance._old_statut_ceo = None
            instance._old_variete = None
    else:
        instance._old_recu_physiquement = False
        instance._old_statut_collecteur = None
        instance._old_statut_labo = None
        instance._old_statut_ceo = None
        instance._old_variete = None


@receiver(post_save, sender='echantillons.Echantillon')
def on_echantillon_saved(sender, instance, created, **kwargs):
    ref = _sample_ref(instance)

    if created:
        recipients = _get_users_by_roles(
            User.Role.DIRECTION,
            User.Role.CHEF_PANEL,
            User.Role.DEGUSTATEUR,
        )
        _notify(
            recipients,
            Notification.Type.NOUVEL_ECHANTILLON,
            'Nouvel echantillon',
            f"L'echantillon {ref} a ete enregistre.",
            echantillon=instance,
            section=Notification.Section.ECHANTILLONS,
        )
        return

    old_recu = getattr(instance, '_old_recu_physiquement', None)
    old_statut = getattr(instance, '_old_statut_collecteur', None)

    if old_recu is False and instance.recu_physiquement:
        now = timezone.now()
        recipients = _get_users_by_roles(User.Role.DIRECTION, User.Role.CHEF_PANEL)
        _notify(
            recipients,
            Notification.Type.ECHANTILLON_RECU,
            'Echantillon recu physiquement',
            (
                f"L'echantillon {ref} a ete marque comme recu physiquement "
                f"le {now.strftime('%d/%m/%Y a %H:%M')}."
            ),
            echantillon=instance,
            section=Notification.Section.ECHANTILLONS,
        )
    elif old_statut != 'achat_confirme' and instance.statut_collecteur == 'achat_confirme':
        recipients = _get_users_by_roles(User.Role.DIRECTION, User.Role.CHEF_PANEL)
        _notify(
            recipients,
            Notification.Type.ACHAT_CONFIRME,
            'Achat confirme',
            f"L'achat de {ref} a ete confirme.",
            echantillon=instance,
            section=Notification.Section.ACHATS,
        )
    else:
        meaningful_change = (
            getattr(instance, '_old_statut_labo', instance.statut_labo) != instance.statut_labo
            or getattr(instance, '_old_statut_ceo', instance.statut_ceo) != instance.statut_ceo
            or getattr(instance, '_old_variete', instance.variete) != instance.variete
        )
        if meaningful_change:
            recipients = _get_users_by_roles(User.Role.DIRECTION, User.Role.CHEF_PANEL)
            _notify(
                recipients,
                Notification.Type.ECHANTILLON_MODIFIE,
                'Echantillon modifie',
                f"L'echantillon {ref} a ete modifie.",
                echantillon=instance,
                section=Notification.Section.ECHANTILLONS,
            )


@receiver(pre_delete, sender='echantillons.Echantillon')
def on_echantillon_deleted(sender, instance, **kwargs):
    ref = _sample_ref(instance)
    recipients = _get_users_by_roles(User.Role.DIRECTION, User.Role.CHEF_PANEL)
    _notify(
        recipients,
        Notification.Type.ECHANTILLON_SUPPRIME,
        'Echantillon supprime',
        f"L'echantillon {ref} a ete supprime.",
        echantillon=None,
        section=Notification.Section.ECHANTILLONS,
    )


@receiver(post_save, sender='evaluations.EvaluationOrganoleptique')
def on_evaluation_saved(sender, instance, created, **kwargs):
    if instance.statut != 'soumis':
        return

    echantillon = instance.echantillon
    ref = _sample_ref(echantillon)
    submitted_count = sender.objects.filter(
        echantillon=echantillon,
        statut='soumis',
    ).values('degustateur').distinct().count()
    active_taster_count = User.objects.filter(
        is_active=True,
        role__in=[User.Role.DEGUSTATEUR, User.Role.CHEF_PANEL],
    ).count()

    if active_taster_count and submitted_count >= active_taster_count:
        recipients = _get_users_by_roles(User.Role.DIRECTION, User.Role.CHEF_PANEL)
        _notify(
            recipients,
            Notification.Type.TOUTES_EVALUATIONS,
            'Toutes les evaluations soumises',
            f"Toutes les evaluations de {ref} sont soumises.",
            echantillon=echantillon,
            section=Notification.Section.EVALUATIONS,
        )
    else:
        recipients = _get_users_by_roles(User.Role.CHEF_PANEL).exclude(id=instance.degustateur_id)
        _notify(
            recipients,
            Notification.Type.EVALUATION_SOUMISE,
            'Evaluation soumise',
            f"Une evaluation de {ref} a ete soumise.",
            echantillon=echantillon,
            section=Notification.Section.EVALUATIONS,
        )


@receiver(post_save, sender='analyses.AnalyseLabo')
def on_analyse_saved(sender, instance, created, **kwargs):
    if instance.statut != 'soumis':
        return

    echantillon = instance.echantillon
    ref = _sample_ref(echantillon)
    recipients = _get_users_by_roles(User.Role.DIRECTION, User.Role.CHEF_PANEL)
    _notify(
        recipients,
        Notification.Type.ANALYSE_SOUMISE,
        'Analyse soumise',
        f"L'analyse de {ref} a ete soumise.",
        echantillon=echantillon,
        section=Notification.Section.ANALYSES,
    )


@receiver(post_save, sender='sessions_degustation.SessionDegustation')
def on_session_saved(sender, instance, created, **kwargs):
    if not created:
        return

    creator = instance.cree_par
    if creator and creator.role == User.Role.DEGUSTATEUR:
        recipients = _get_users_by_roles(User.Role.CHEF_PANEL)
    else:
        recipients = instance.participants.filter(is_active=True)

    _notify(
        recipients,
        Notification.Type.NOUVELLE_SESSION,
        'Nouvelle session',
        f"La session {instance.titre} a ete creee.",
        echantillon=None,
        section=Notification.Section.SESSIONS,
    )
