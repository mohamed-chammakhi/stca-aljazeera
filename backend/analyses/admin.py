from django.contrib import admin
from .models import AnalyseLabo, CritereAnalyse


class CritereInline(admin.TabularInline):
    model  = CritereAnalyse
    extra  = 0
    fields = ('label', 'valeur', 'unite', 'seuil_min', 'seuil_max')


@admin.register(AnalyseLabo)
class AnalyseLaboAdmin(admin.ModelAdmin):
    list_display  = ('echantillon', 'technicien', 'statut', 'priorite', 'created_at')
    list_filter   = ('statut', 'priorite')
    search_fields = ('echantillon__ref', 'technicien__nom', 'numero_lot')
    readonly_fields = ('id', 'created_at', 'submitted_at')
    inlines = [CritereInline]
