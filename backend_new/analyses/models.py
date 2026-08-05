import uuid
from django.db import models
from django.conf import settings

from . import normes_coi


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

    # ── Identification du certificat ────────────────────────────────────────
    # Ce que porte l'en-tete du rapport papier et que l'echantillon ne connait
    # pas deja. L'importateur, la facture et les adresses concernent la vente a
    # l'export, pas la decision d'achat : ils restent sur le papier.
    numero_certificat  = models.CharField(max_length=50, blank=True)
    numero_lot         = models.CharField(max_length=50, blank=True)
    date_debut_analyse = models.DateField(null=True, blank=True)
    date_fin_analyse   = models.DateField(null=True, blank=True)
    quantite_ml        = models.PositiveIntegerField(null=True, blank=True)

    # ── Tableau 1 — resultats principaux ────────────────────────────────────
    acidite         = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    indice_peroxyde = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    k232            = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    k270            = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    delta_k         = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    humidite        = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    impuretes       = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    ecn42           = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)

    # ── Tableau 2 — composition en sterols (% des sterols totaux) ───────────
    cholesterol              = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    brassicasterol           = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    campesterol              = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    stigmasterol             = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    beta_sitosterol_apparent = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    delta_7_stigmastenol     = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    delta_7_avenasterol      = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    erythrodiol_uvaol        = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)

    # ── Tableau 3 — esters methyliques d'acides gras (%) ────────────────────
    acide_palmitique      = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_palmitoleique   = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_heptadecanoique = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_heptadecenoique = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_stearique       = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_oleique         = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_linoleique      = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_linolenique     = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_arachidique     = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    acide_gadoleique      = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    trans_c18_1           = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)
    trans_c18_2_c18_3     = models.DecimalField(max_digits=6, decimal_places=3, null=True, blank=True)

    photo = models.ImageField(upload_to='analyses/', null=True, blank=True)
    notes = models.TextField(blank=True)
    date_analyse = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    # ── Lecture des valeurs ─────────────────────────────────────────────────
    def valeurs(self):
        """Les 28 valeurs mesurees, par cle de parametre."""
        return {p.cle: getattr(self, p.cle, None) for p in normes_coi.TOUS_PARAMETRES}

    @property
    def classification(self):
        """Classement COI deduit des valeurs. None tant qu'il manque une des
        quatre grandeurs obligatoires."""
        return normes_coi.classification_coi(self.valeurs())

    @property
    def parametres_hors_normes(self):
        """Les cles des parametres saisis qui sortent de la norme COI.

        C'est ce qui declenche l'alerte envoyee a la direction : une valeur
        peut sortir de la norme sans que le classement change, notamment sur
        les sterols et les acides gras, qui trahissent un melange.
        """
        return [p.cle for p in normes_coi.parametres_hors_normes(self.valeurs())]


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
