import uuid
from django.db import models


class PlanificationArrivage(models.Model):
    """When the sample is expected to arrive at the company (before physical receipt)."""

    class Mode(models.TextChoices):
        DATE_EXACTE = 'date_exacte', 'Date exacte'
        PERIODE     = 'periode',     'Période'

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon  = models.OneToOneField(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='planification_arrivage'
    )
    mode         = models.CharField(max_length=20, choices=Mode.choices, default=Mode.DATE_EXACTE)
    date_exacte  = models.DateField(null=True, blank=True)
    periode_debut = models.DateField(null=True, blank=True)
    periode_fin  = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"Arrivage pour {self.echantillon}"


class PlanificationLivraison(models.Model):
    """When the purchased stock is expected to be delivered to the company."""

    class Mode(models.TextChoices):
        DATE_EXACTE = 'date_exacte', 'Date exacte'
        PERIODE     = 'periode',     'Période'

    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon = models.OneToOneField(
        'echantillons.Echantillon',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='planification_livraison'
    )
    mode          = models.CharField(max_length=20, choices=Mode.choices, default=Mode.DATE_EXACTE)
    date_exacte   = models.DateField(null=True, blank=True)
    periode_debut = models.DateField(null=True, blank=True)
    periode_fin   = models.DateField(null=True, blank=True)
    heure         = models.TimeField(null=True, blank=True)
    lieu          = models.CharField(max_length=200, blank=True)
    camion        = models.CharField(max_length=50, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Livraison pour {self.echantillon}"
