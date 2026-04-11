import uuid
from django.db import models
from django.conf import settings


class Message(models.Model):
    id             = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    expediteur     = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='messages_envoyes',
    )
    destinataire   = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='messages_recus',
    )
    contenu        = models.TextField()
    lu             = models.BooleanField(default=False)
    lu_le          = models.DateTimeField(null=True, blank=True)
    created_at     = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'messages'
        ordering = ['created_at']

    def __str__(self):
        return f'{self.expediteur} → {self.destinataire}: {self.contenu[:40]}'
