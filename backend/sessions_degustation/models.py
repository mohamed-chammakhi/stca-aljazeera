import uuid
from django.db import models
from django.conf import settings


class StatutSession(models.TextChoices):
    PLANIFIEE = 'planifiee', 'Planifiée'
    EN_COURS  = 'en_cours',  'En cours'
    TERMINEE  = 'terminee',  'Terminée'


class SessionDegustation(models.Model):
    id     = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    titre  = models.CharField(max_length=200)
    date   = models.DateField()
    heure  = models.CharField(max_length=10)   # "HH:MM" — 24h
    lieu   = models.CharField(max_length=200)
    statut = models.CharField(max_length=20, choices=StatutSession.choices, default=StatutSession.PLANIFIEE)
    notes  = models.TextField(blank=True, null=True)

    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='sessions_creees',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    # ── M2M relationships (junction tables managed by Django) ────────────────
    echantillons = models.ManyToManyField(
        'echantillons.Echantillon',
        related_name='sessions',
        blank=True,
        db_table='session_echantillons',
    )
    participants = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='sessions_participees',
        blank=True,
        db_table='session_participants',
        limit_choices_to={'role': 'degustateur'},
    )

    class Meta:
        db_table = 'sessions_degustation'
        ordering = ['-date', '-heure']

    def __str__(self):
        return f'{self.titre} ({self.date})'
