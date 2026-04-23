import uuid
from django.db import models
from django.conf import settings


class EvaluationOrganoleptique(models.Model):

    class Statut(models.TextChoices):
        EN_COURS = 'en_cours', 'En cours'
        SOUMIS   = 'soumis',   'Soumis'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    echantillon = models.ForeignKey(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='evaluations'
    )
    degustateur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='evaluations'
    )
    # Which tasting session this evaluation belongs to (optional)
    session = models.ForeignKey(
        'sessions_degustation.SessionDegustation',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='evaluations'
    )

    statut = models.CharField(
        max_length=20, choices=Statut.choices, default=Statut.EN_COURS
    )

    # Quality classification result of this evaluation
    classification = models.CharField(max_length=20, blank=True)

    # Positive attributes (score 0–10)
    fruite      = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    fruite_vert = models.BooleanField(default=True)  # True = green/immature fruit, False = ripe
    amertume    = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    piquant     = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)

    # Defect attributes (score 0–10)
    chome          = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    moisi          = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    vinaigre       = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    rance          = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    gele           = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    autres_defaut     = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    autres_defaut_nom = models.CharField(max_length=100, blank=True)

    commentaire = models.TextField(blank=True)

    # soumis_le is set when evaluation is submitted (statut → soumis)
    soumis_le        = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['echantillon', 'degustateur']

    def __str__(self):
        return f"Evaluation de {self.degustateur} pour {self.echantillon}"
