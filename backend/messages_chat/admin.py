from django.contrib import admin
from .models import Message


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display  = ('expediteur', 'destinataire', 'lu', 'created_at')
    list_filter   = ('lu',)
    search_fields = ('expediteur__nom', 'destinataire__nom', 'contenu')
    readonly_fields = ('id', 'created_at')
