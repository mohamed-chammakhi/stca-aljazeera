from django.contrib import admin
from .models import SessionDegustation


@admin.register(SessionDegustation)
class SessionAdmin(admin.ModelAdmin):
    list_display  = ('titre', 'date', 'heure', 'lieu', 'statut', 'created_by')
    list_filter   = ('statut',)
    search_fields = ('titre', 'lieu')
    readonly_fields = ('id', 'created_at')
    filter_horizontal = ('echantillons', 'participants')
