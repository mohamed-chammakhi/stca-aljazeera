import uuid
from django.db import models


class Fournisseur(models.Model):
    id               = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom              = models.CharField(max_length=200)
    region           = models.CharField(max_length=100, blank=True)
    delegation       = models.CharField(max_length=100, blank=True)
    telephone        = models.CharField(max_length=20, blank=True)
    email            = models.EmailField(blank=True)
    adresse          = models.TextField(blank=True)
    notes            = models.TextField(blank=True)
    date_premiere_contact = models.DateTimeField(null=True, blank=True)
    date_creation    = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nom
