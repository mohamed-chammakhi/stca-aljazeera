from django.contrib import admin
from .models import PlanificationArrivage, PlanificationLivraison


@admin.register(PlanificationArrivage)
class PlanificationArrivageAdmin(admin.ModelAdmin):
    list_display  = ('echantillon', 'mode', 'date_exacte', 'periode_debut', 'periode_fin')
    list_filter   = ('mode',)
    search_fields = ('echantillon__ref',)


@admin.register(PlanificationLivraison)
class PlanificationLivraisonAdmin(admin.ModelAdmin):
    list_display    = ('echantillon', 'mode', 'date_exacte', 'lieu', 'camion', 'date_creation')
    list_filter     = ('mode',)
    search_fields   = ('echantillon__ref', 'lieu', 'camion')
    readonly_fields = ('date_creation',)
