from django.contrib import admin
from .models import EvaluationOrganoleptique


@admin.register(EvaluationOrganoleptique)
class EvaluationOrganoleptiqueAdmin(admin.ModelAdmin):
    list_display    = ('echantillon', 'degustateur', 'statut', 'soumis_le')
    list_filter     = ('statut',)
    search_fields   = ('echantillon__ref', 'degustateur__email')
    readonly_fields = ('soumis_le', 'date_modification')
