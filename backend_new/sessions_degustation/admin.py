from django.contrib import admin
from .models import SessionDegustation


@admin.register(SessionDegustation)
class SessionDegustationAdmin(admin.ModelAdmin):
    list_display      = ('titre', 'date', 'heure', 'lieu', 'statut', 'cree_par', 'date_creation')
    list_filter       = ('statut',)
    search_fields     = ('titre', 'lieu')
    filter_horizontal = ('participants', 'echantillons')
    readonly_fields   = ('date_creation',)
