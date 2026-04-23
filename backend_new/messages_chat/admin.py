from django.contrib import admin
from .models import Message


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display    = ('expediteur', 'destinataire', 'lu', 'date_envoi')
    list_filter     = ('lu',)
    search_fields   = ('expediteur__email', 'destinataire__email', 'contenu')
    ordering        = ('-date_envoi',)
    readonly_fields = ('date_envoi',)
