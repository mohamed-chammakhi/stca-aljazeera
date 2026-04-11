from django.contrib import admin
from .models import EvaluationOrganoleptique


@admin.register(EvaluationOrganoleptique)
class EvaluationAdmin(admin.ModelAdmin):
    list_display  = ('echantillon', 'tasteur', 'classification', 'soumis_le')
    list_filter   = ('classification',)
    search_fields = ('echantillon__ref', 'tasteur__nom')
    readonly_fields = ('id', 'soumis_le')
