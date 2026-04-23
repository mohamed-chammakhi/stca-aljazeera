import uuid
from django.db import models
from django.conf import settings


class Message(models.Model):

    # Unique ID generated automatically
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Who sent the message
    expediteur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='messages_envoyes'
    )

    # Who receives the message
    destinataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='messages_recus'
    )

    # The actual message text
    contenu = models.TextField()

    # False = not yet read by the recipient, True = already read
    lu    = models.BooleanField(default=False)
    lu_le = models.DateTimeField(null=True, blank=True)

    # Automatically set when message is created
    date_envoi = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.expediteur} → {self.destinataire}: {self.contenu[:30]}"
