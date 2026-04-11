from django.contrib import admin
from .models import Fournisseur


@admin.register(Fournisseur)
class FournisseurAdmin(admin.ModelAdmin):
    list_display  = ('code_fournisseur', 'nom', 'region', 'telephone', 'email')
    search_fields = ('nom', 'code_fournisseur', 'region')
    ordering      = ('nom',)
