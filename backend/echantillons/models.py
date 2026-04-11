import uuid
from django.db import models
from django.conf import settings


class StatutCollecteur(models.TextChoices):
    RECEPTIONNE    = 'receptionne',    'Réceptionné'
    EN_NEGOCIATION = 'en_negociation', 'En négociation'
    ACHAT_CONFIRME = 'achat_confirme', 'Achat confirmé'


class StatutDegustateur(models.TextChoices):
    EN_ATTENTE = 'en_attente', 'En attente'
    EN_COURS   = 'en_cours',   'En cours'
    SOUMIS     = 'soumis',     'Soumis'


class StatutLabo(models.TextChoices):
    EN_ATTENTE = 'en_attente', 'En attente'
    EN_COURS   = 'en_cours',   'En cours'
    SOUMIS     = 'soumis',     'Soumis'


class StatutCeo(models.TextChoices):
    SELECTIONNE    = 'selectionne',    'Sélectionné'
    EN_NEGOCIATION = 'en_negociation', 'En négociation'
    ACHAT_CONFIRME = 'achat_confirme', 'Achat confirmé'
    REFUSE         = 'refuse',         'Refusé'


class ClassificationHuile(models.TextChoices):
    EXTRA_VIERGE    = 'extra_vierge',    'Extra Vierge'
    VIERGE          = 'vierge',          'Vierge'
    VIERGE_ORDINAIRE = 'vierge_ordinaire', 'Vierge Ordinaire'
    LAMPANTE        = 'lampante',        'Lampante'


class Echantillon(models.Model):
    # ── Primary key & display reference ──────────────────────────────────────
    id  = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ref = models.CharField(max_length=20, unique=True)  # e.g. "2026/0001"

    # ── Foreign keys ──────────────────────────────────────────────────────────
    fournisseur = models.ForeignKey(
        'fournisseurs.Fournisseur',
        on_delete=models.PROTECT,
        related_name='echantillons',
    )
    collecteur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='echantillons_collectes',
        limit_choices_to={'role': 'collecteur'},
    )

    # ── Location ──────────────────────────────────────────────────────────────
    gouvernorat = models.CharField(max_length=100)
    delegation  = models.CharField(max_length=100, blank=True, null=True)
    cite        = models.CharField(max_length=100, blank=True, null=True)

    # ── Bottle identity ───────────────────────────────────────────────────────
    reference_bouteille = models.CharField(max_length=100)
    scellage            = models.CharField(max_length=100, blank=True, null=True)
    variete             = models.CharField(max_length=100, blank=True, null=True)
    quantite_estimee    = models.CharField(max_length=50,  blank=True, null=True)
    image_url           = models.ImageField(upload_to='echantillons/images/', blank=True, null=True)

    # ── Per-role statuses ─────────────────────────────────────────────────────
    statut_collecteur  = models.CharField(
        max_length=20, choices=StatutCollecteur.choices,
        default=StatutCollecteur.RECEPTIONNE,
    )
    statut_degustateur = models.CharField(
        max_length=20, choices=StatutDegustateur.choices,
        blank=True, null=True,
    )
    statut_labo = models.CharField(
        max_length=20, choices=StatutLabo.choices,
        blank=True, null=True,
    )
    statut_ceo = models.CharField(
        max_length=20, choices=StatutCeo.choices,
        blank=True, null=True,
    )

    # ── Physical reception ────────────────────────────────────────────────────
    recu_physiquement       = models.BooleanField(default=False)
    date_arrivee_echantillon = models.DateTimeField(blank=True, null=True)

    # ── CEO negotiation & purchase ────────────────────────────────────────────
    budget_negociation         = models.DecimalField(max_digits=10, decimal_places=3, blank=True, null=True)
    quantite_cible_t           = models.DecimalField(max_digits=10, decimal_places=3, blank=True, null=True)
    camion_reserve             = models.CharField(max_length=50, blank=True, null=True)
    note_interne               = models.TextField(blank=True, null=True)
    raison_refus               = models.TextField(blank=True, null=True)
    stock_arrive               = models.BooleanField(default=False)
    date_livraison_stock       = models.DateField(blank=True, null=True)

    # ── Final classification ──────────────────────────────────────────────────
    classification = models.CharField(
        max_length=20, choices=ClassificationHuile.choices,
        blank=True, null=True,
    )

    # ── Shared notes ──────────────────────────────────────────────────────────
    remarques = models.TextField(blank=True, null=True)

    # ── Timestamps ────────────────────────────────────────────────────────────
    date_ajout = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'echantillons'
        ordering = ['-date_ajout']

    def __str__(self):
        return self.ref
