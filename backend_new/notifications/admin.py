from django.contrib import admin
from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display    = ('destinataire', 'type', 'titre', 'section', 'is_read', 'date_creation')
    list_filter     = ('type', 'section', 'is_read')
    search_fields   = ('destinataire__email', 'titre')
    ordering        = ('-date_creation',)
    readonly_fields = ('date_creation',)