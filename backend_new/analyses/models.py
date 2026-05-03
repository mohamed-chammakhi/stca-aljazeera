import uuid
from django.db import models
from django.conf import settings


class AnalyseLabo(models.Model):

    class Statut(models.TextChoices):
        EN_COURS = 'en_cours', 'En cours'
        SOUMIS = 'soumis', 'Soumis'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    echantillon = models.OneToOneField(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='analyse'
    )
    technicien = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='analyses'
    )

    statut = models.CharField(
        max_length=20,
        choices=Statut.choices,
        default=Statut.EN_COURS
    )

    acidite         = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    indice_peroxyde = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    k232            = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    k270            = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    delta_k         = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    humidite        = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    impuretes       = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)

    photo = models.ImageField(upload_to='analyses/', null=True, blank=True)
    notes = models.TextField(blank=True)
    date_analyse = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)


class CritereAnalyse(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    analyse = models.ForeignKey(
        AnalyseLabo,
        on_delete=models.CASCADE,
        related_name='criteres'
    )
    label      = models.CharField(max_length=100)
    valeur     = models.DecimalField(max_digits=10, decimal_places=4)
    unite      = models.CharField(max_length=20, blank=True)
    valeur_min = models.DecimalField(max_digits=10, decimal_places=4, null=True, blank=True)
    valeur_max = models.DecimalField(max_digits=10, decimal_places=4, null=True, blank=True)
    # Whether this criterion's value is within acceptable quality standards
    conforme   = models.BooleanField(null=True, blank=True)

    def __str__(self):
        return f"{self.label}: {self.valeur} {self.unite}"
