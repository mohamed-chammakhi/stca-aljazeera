from django.contrib import admin
from .models import PlanificationArrivage, PlanificationLivraison


@admin.register(PlanificationArrivage)
class PlanificationArrivageAdmin(admin.ModelAdmin):
    list_display = ('echantillon', 'mode', 'date_exacte', 'periode_debut', 'periode_fin')
    readonly_fields = ('id',)


@admin.register(PlanificationLivraison)
class PlanificationLivraisonAdmin(admin.ModelAdmin):
    list_display = ('echantillon', 'mode', 'heure', 'lieu', 'camion')
    readonly_fields = ('id',)
