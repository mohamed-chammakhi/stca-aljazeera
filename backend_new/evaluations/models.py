import uuid
from django.db import models
from django.conf import settings


class EvaluationOrganoleptique(models.Model):

    class Statut(models.TextChoices):
        EN_COURS = 'en_cours', 'En cours'
        SOUMIS   = 'soumis',   'Soumis'

    class TypeFruite(models.TextChoices):
        VERT     = 'vert',     'Vert'
        VERT_MUR = 'vert_mur', 'Vert-mûr'
        MUR      = 'mur',      'Mûr'

    class ClasseInterne(models.TextChoices):
        """Classes internes PR-48 §8, plus « Extra déséquilibrée » (§6 et §9)."""
        EXTRA_A_PLUS       = 'extra_a_plus',       'Extra A+'
        EXTRA_A            = 'extra_a',            'Extra A'
        EXTRA_B_PLUS       = 'extra_b_plus',       'Extra B+'
        EXTRA_B            = 'extra_b',            'Extra B'
        EXTRA_B_MOINS      = 'extra_b_moins',      'Extra B−'
        EXTRA_C            = 'extra_c',            'Extra C'
        EXTRA_DESEQUILIBRE = 'extra_desequilibre', 'Extra déséquilibrée'

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

    # Niveau 1 — catégorie réglementaire COI
    classification = models.CharField(max_length=20, blank=True)

    # Niveau 2 — classe interne PR-48, applicable aux seules huiles extra vierges (§6)
    classe_interne = models.CharField(
        max_length=20, choices=ClasseInterne.choices, blank=True
    )
    # Vrai quand aucune ligne de la grille §8 ne correspondait et que le
    # dégustateur a choisi la classe lui-même.
    classe_interne_manuelle = models.BooleanField(default=False)
    # Motif « hors grille » figé au moment du choix (traçabilité §14).
    classe_interne_motif = models.CharField(max_length=200, blank=True)
    # Horodatage du choix manuel. Champ dédié : date_modification est en auto_now
    # et bougerait à chaque enregistrement.
    classe_interne_choisie_le = models.DateTimeField(null=True, blank=True)
    # Critère « profil harmonieux » (§8) / « priorité à l'équilibre » (§9).
    # Le PR-48 ne le chiffre pas — c'est le dégustateur qui juge.
    profil_non_harmonieux = models.BooleanField(default=False)

    # Positive attributes (score 0–5 — échelle PR-48)
    fruite      = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    type_fruite = models.CharField(
        max_length=10, choices=TypeFruite.choices, default=TypeFruite.VERT
    )
    amertume    = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    piquant     = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)

    # Defect attributes (score 0–10 — échelle COI, hors périmètre du PR-48)
    chome          = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    moisi          = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    vinaigre       = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    rance          = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    gele           = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    autres_defaut     = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    autres_defaut_nom = models.CharField(max_length=100, blank=True)

    commentaire = models.TextField(blank=True)

    # soumis_le is set when evaluation is submitted (statut → soumis)
    soumis_le        = models.DateTimeField(null=True, blank=True)
    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['echantillon', 'degustateur']

    def __str__(self):
        return f"Evaluation de {self.degustateur} pour {self.echantillon}"
