import uuid
from django.db import models
from django.conf import settings


class Notification(models.Model):

    class Type(models.TextChoices):
        NOUVEL_ECHANTILLON   = 'NOUVEL_ECHANTILLON',   'Nouvel échantillon'
        ECHANTILLON_MODIFIE  = 'ECHANTILLON_MODIFIE',  'Échantillon modifié'
        ECHANTILLON_SUPPRIME = 'ECHANTILLON_SUPPRIME', 'Échantillon supprimé'
        ECHANTILLON_RECU     = 'ECHANTILLON_RECU',     'Échantillon reçu physiquement'
        PREMIERE_EVALUATION  = 'PREMIERE_EVALUATION',  'Première évaluation soumise'
        TOUTES_EVALUATIONS   = 'TOUTES_EVALUATIONS',   'Toutes les évaluations soumises'
        ANALYSE_SOUMISE      = 'ANALYSE_SOUMISE',      'Analyse laboratoire soumise'
        ACHAT_CONFIRME       = 'ACHAT_CONFIRME',       'Achat confirmé'

    class Section(models.TextChoices):
        ECHANTILLONS = 'ECHANTILLONS', 'Échantillons'
        EVALUATIONS  = 'EVALUATIONS',  'Évaluations'
        ANALYSES     = 'ANALYSES',     'Analyses'
        ACHATS       = 'ACHATS',       'Achats'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    destinataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    type = models.CharField(max_length=40, choices=Type.choices)
    titre = models.CharField(max_length=200)
    message = models.TextField()
    echantillon = models.ForeignKey(
        'echantillons.Echantillon',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='notifications'
    )
    section = models.CharField(max_length=20, choices=Section.choices, default=Section.ECHANTILLONS)
    is_read = models.BooleanField(default=False)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return f"[{self.type}] → {self.destinataire} : {self.titre}"
