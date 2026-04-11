from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display  = ('email', 'nom', 'prenom', 'role', 'is_active', 'date_creation')
    list_filter   = ('role', 'is_active')
    search_fields = ('email', 'nom', 'prenom')
    ordering      = ('nom',)

    fieldsets = (
        (None,           {'fields': ('email', 'password')}),
        ('Informations', {'fields': ('nom', 'prenom', 'telephone', 'photo_url')}),
        ('Rôle & accès', {'fields': ('role', 'is_active', 'is_staff', 'is_superuser')}),
        ('Dates',        {'fields': ('date_creation', 'last_login')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'nom', 'prenom', 'role'),
        }),
    )
    readonly_fields = ('date_creation', 'last_login')
