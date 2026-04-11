import uuid
from django.db import models


class ModePlanification(models.TextChoices):
    DATE_EXACTE = 'date_exacte', 'Date exacte'
    PERIODE     = 'periode',     'Période'


class PlanificationArrivage(models.Model):
    """Expected arrival window for the sample bottle at company HQ."""
    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon  = models.OneToOneField(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='planification_arrivage',
    )
    mode         = models.CharField(max_length=20, choices=ModePlanification.choices)
    date_exacte  = models.DateTimeField(null=True, blank=True)
    periode_debut = models.DateTimeField(null=True, blank=True)
    periode_fin   = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'planifications_arrivage'

    def __str__(self):
        return f'Arrivage — {self.echantillon.ref}'


class PlanificationLivraison(models.Model):
    """Full-stock delivery plan — created after achat_confirme."""
    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon  = models.OneToOneField(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='planification_livraison',
    )
    mode          = models.CharField(max_length=20, choices=ModePlanification.choices)
    date_exacte   = models.DateTimeField(null=True, blank=True)
    periode_debut = models.DateTimeField(null=True, blank=True)
    periode_fin   = models.DateTimeField(null=True, blank=True)
    heure         = models.CharField(max_length=10)   # "09:30 AM"
    lieu          = models.CharField(max_length=200)
    camion        = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        db_table = 'planifications_livraison'

    def __str__(self):
        return f'Livraison — {self.echantillon.ref}'
