import uuid
from django.db import models
from django.conf import settings
from echantillons.models import ClassificationHuile


class EvaluationOrganoleptique(models.Model):
    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    echantillon  = models.ForeignKey(
        'echantillons.Echantillon',
        on_delete=models.CASCADE,
        related_name='evaluations',
    )
    tasteur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='evaluations',
        limit_choices_to={'role': 'degustateur'},
    )
    session = models.ForeignKey(
        'sessions_degustation.SessionDegustation',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='evaluations',
    )

    # ── Classification result ─────────────────────────────────────────────────
    classification = models.CharField(max_length=20, choices=ClassificationHuile.choices)
    soumis_le      = models.DateTimeField(auto_now_add=True)

    # ── Positive attributes (COI scale 0–10) ──────────────────────────────────
    fruite      = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    fruite_vert = models.BooleanField(default=True)  # True = Vert, False = Mûr
    amertume    = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    piquant     = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)

    # ── Defect attributes (COI scale 0–10; 0 = absent) ────────────────────────
    chome           = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    moisi           = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    vinaigre        = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    gele            = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    rance           = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    autres_defaut   = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    autres_defaut_nom = models.CharField(max_length=100, blank=True, null=True)

    commentaire = models.TextField(blank=True, null=True)

    class Meta:
        db_table = 'evaluations_organoleptiques'
        # One evaluation per (sample × taster)
        unique_together = [('echantillon', 'tasteur')]
        ordering = ['-soumis_le']

    def __str__(self):
        return f'Éval {self.echantillon.ref} par {self.tasteur.nom_complet}'
