from django.contrib import admin
from .models import Echantillon


@admin.register(Echantillon)
class EchantillonAdmin(admin.ModelAdmin):
    list_display  = ('ref', 'fournisseur', 'collecteur', 'gouvernorat', 'statut_collecteur', 'recu_physiquement', 'date_ajout')
    list_filter   = ('statut_collecteur', 'statut_ceo', 'statut_labo', 'recu_physiquement', 'gouvernorat')
    search_fields = ('ref', 'reference_bouteille', 'gouvernorat')
    ordering      = ('-date_ajout',)
    readonly_fields = ('id', 'date_ajout', 'updated_at')
