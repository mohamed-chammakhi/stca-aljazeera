import uuid
from django.db import models


class Fournisseur(models.Model):
    id                   = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code_fournisseur     = models.CharField(max_length=20, unique=True)
    nom                  = models.CharField(max_length=200)
    region               = models.CharField(max_length=100, blank=True, null=True)
    telephone            = models.CharField(max_length=30,  blank=True, null=True)
    email                = models.EmailField(blank=True, null=True)
    adresse              = models.TextField(blank=True, null=True)
    notes                = models.TextField(blank=True, null=True)
    date_premiere_contact = models.DateField(blank=True, null=True)

    class Meta:
        db_table = 'fournisseurs'
        ordering = ['nom']

    def __str__(self):
        return f'{self.code_fournisseur} — {self.nom}'

    # ── Computed counters (annotated by the serializer / queryset) ────────────
    @property
    def nb_echantillons_soumis(self):
        return self.echantillons.count()

    @property
    def nb_achats_confirmes(self):
        return self.echantillons.filter(statut_collecteur='achat_confirme').count()
