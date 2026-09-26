from django.contrib import admin
from .models import Fournisseur


@admin.register(Fournisseur)
class FournisseurAdmin(admin.ModelAdmin):
    list_display  = ('nom', 'region', 'delegation', 'telephone', 'email', 'date_creation')
    search_fields = ('nom', 'region', 'delegation')
    ordering      = ('nom', 'region', 'delegation')
