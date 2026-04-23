from django.contrib import admin
from .models import Fournisseur


@admin.register(Fournisseur)
class FournisseurAdmin(admin.ModelAdmin):
    list_display  = ('nom', 'code_fournisseur', 'region', 'telephone', 'email', 'date_creation')
    search_fields = ('nom', 'code_fournisseur', 'region')
    ordering      = ('nom',)
