import uuid
from django.db import models
from django.conf import settings


class SessionDegustation(models.Model):

    # The 5 possible states of a tasting session
    class Statut(models.TextChoices):
        EN_ATTENTE_VALIDATION = 'en_attente_validation', 'En attente de validation'  # created, awaiting chef_panel approval
        PLANIFIEE             = 'planifiee',             'Planifiée'                 # approved, scheduled
        EN_COURS              = 'en_cours',              'En cours'                  # currently happening
        TERMINEE              = 'terminee',              'Terminée'                  # finished
        REFUSEE               = 'refusee',               'Refusée'                   # refused by chef_panel

    # Unique ID for each session — Django generates it automatically
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Basic session info filled by the taster when creating the session
    titre = models.CharField(max_length=200)   # session title
    date = models.DateField()                  # which day
    heure = models.TimeField()                 # what time
    lieu = models.CharField(max_length=200)    # where (room, location)
    notes = models.TextField(blank=True)       # optional extra notes
    nombre_echantillons_prevus = models.PositiveIntegerField(null=True, blank=True)

    # Current state of the session — starts as Planifiée by default
    statut = models.CharField(
        max_length=25,
        choices=Statut.choices,
        default=Statut.EN_ATTENTE_VALIDATION
    )

    # Who created this session — one taster creates it
    # SET_NULL = if that user is deleted, don't delete the session, just set this to empty
    cree_par = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='sessions_creees'
    )

    # Which tasters are invited — one session has many participants,
    # one taster can be in many sessions → ManyToMany
    participants = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='sessions_invitees',
        blank=True   # a session can be created with no participants yet
    )
    presences_confirmees = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='sessions_presence_confirmee',
        blank=True
    )

    # Which samples will be tasted in this session —
    # one session can have many samples, one sample can appear in many sessions
    echantillons = models.ManyToManyField(
        'echantillons.Echantillon',
        related_name='sessions',
        blank=True   # optional — can be added later
    )

    # Automatically set to the date/time when the session record is created
    date_creation = models.DateTimeField(auto_now_add=True)

    # How Django displays this object as text (e.g. in the admin panel)
    def __str__(self):
        return self.titre
