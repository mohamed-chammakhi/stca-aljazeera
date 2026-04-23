from django.contrib import admin
from .models import AnalyseLabo, CritereAnalyse


class CritereAnalyseInline(admin.TabularInline):
    model  = CritereAnalyse
    extra  = 0
    fields = ('label', 'valeur', 'unite', 'valeur_min', 'valeur_max', 'conforme')


@admin.register(AnalyseLabo)
class AnalyseLaboAdmin(admin.ModelAdmin):
    list_display    = ('echantillon', 'technicien', 'statut', 'date_analyse')
    list_filter     = ('statut',)
    search_fields   = ('echantillon__ref',)
    inlines         = [CritereAnalyseInline]
    readonly_fields = ('date_analyse', 'date_modification')
