import uuid
from django.db import models
from django.conf import settings
from echantillons.models import StatutLabo


class AnalyseLabo(models.Model):
    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon  = models.OneToOneField(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='analyse_labo',
    )
    technicien = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='analyses',
        limit_choices_to={'role': 'laboratoire'},
    )

    date_analyse    = models.DateField(null=True, blank=True)
    statut          = models.CharField(max_length=20, choices=StatutLabo.choices, default=StatutLabo.EN_ATTENTE)
    notes           = models.TextField(blank=True, null=True)
    photo_url       = models.ImageField(upload_to='analyses/photos/', blank=True, null=True)
    numero_lot      = models.CharField(max_length=50,  blank=True, null=True)
    origine_campagne = models.CharField(max_length=20, blank=True, null=True)  # e.g. "2025/2026"

    class Priorite(models.TextChoices):
        NORMALE  = 'normale',  'Normale'
        URGENTE  = 'urgente',  'Urgente'

    priorite        = models.CharField(max_length=10, choices=Priorite.choices, default=Priorite.NORMALE)
    notes_reception = models.TextField(blank=True, null=True)
    submitted_at    = models.DateTimeField(null=True, blank=True)
    created_at      = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'analyses_labo'
        ordering = ['-created_at']

    def __str__(self):
        return f'Analyse {self.echantillon.ref}'


class CritereAnalyse(models.Model):
    """One measurement row per analysis. Flexible — no hardcoded column names."""
    id        = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    analyse   = models.ForeignKey(AnalyseLabo, on_delete=models.CASCADE, related_name='criteres')
    label     = models.CharField(max_length=100)   # e.g. "Acidité libre"
    valeur    = models.DecimalField(max_digits=10, decimal_places=4)
    unite     = models.CharField(max_length=20, blank=True, null=True)
    seuil_min = models.DecimalField(max_digits=10, decimal_places=4, null=True, blank=True)
    seuil_max = models.DecimalField(max_digits=10, decimal_places=4, null=True, blank=True)

    class Meta:
        db_table = 'criteres_analyse'
        ordering = ['label']

    def __str__(self):
        return f'{self.label}: {self.valeur}'

    @property
    def conforme(self):
        """Mirrors the GENERATED ALWAYS logic from the PostgreSQL schema."""
        if self.seuil_min is not None and self.valeur < self.seuil_min:
            return False
        if self.seuil_max is not None and self.valeur > self.seuil_max:
            return False
        return True
