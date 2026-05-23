import uuid

from django.conf import settings
from django.db import models


class Notification(models.Model):
    class Type(models.TextChoices):
        NOUVEL_ECHANTILLON = 'NOUVEL_ECHANTILLON', 'Nouvel echantillon'
        ECHANTILLON_MODIFIE = 'ECHANTILLON_MODIFIE', 'Echantillon modifie'
        ECHANTILLON_SUPPRIME = 'ECHANTILLON_SUPPRIME', 'Echantillon supprime'
        ECHANTILLON_RECU = 'ECHANTILLON_RECU', 'Echantillon recu physiquement'
        PREMIERE_EVALUATION = 'PREMIERE_EVALUATION', 'Premiere evaluation soumise'
        EVALUATION_SOUMISE = 'EVALUATION_SOUMISE', 'Evaluation soumise'
        TOUTES_EVALUATIONS = 'TOUTES_EVALUATIONS', 'Toutes les evaluations soumises'
        ANALYSE_SOUMISE = 'ANALYSE_SOUMISE', 'Analyse laboratoire soumise'
        ACHAT_CONFIRME = 'ACHAT_CONFIRME', 'Achat confirme'
        PROPOSITION_ACHAT_ATTENTE = 'proposition_achat_attente', "Proposition d'achat en attente"
        ANALYSE_URGENTE = 'ANALYSE_URGENTE', 'Analyse urgente demandee'
        NOUVELLE_SESSION = 'NOUVELLE_SESSION', 'Nouvelle session'

    class Section(models.TextChoices):
        ECHANTILLONS = 'ECHANTILLONS', 'Echantillons'
        EVALUATIONS = 'EVALUATIONS', 'Evaluations'
        ANALYSES = 'ANALYSES', 'Analyses'
        ACHATS = 'ACHATS', 'Achats'
        ACHATS_VALIDATION = 'ACHATS_VALIDATION', 'Validation achats'
        SESSIONS = 'SESSIONS', 'Sessions'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    destinataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
    )
    type = models.CharField(max_length=40, choices=Type.choices)
    titre = models.CharField(max_length=200)
    message = models.TextField()
    echantillon = models.ForeignKey(
        'echantillons.Echantillon',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='notifications',
    )
    section = models.CharField(
        max_length=20,
        choices=Section.choices,
        default=Section.ECHANTILLONS,
    )
    is_read = models.BooleanField(default=False)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return f"[{self.type}] -> {self.destinataire}: {self.titre}"
