import django_filters
from .models import Echantillon


class EchantillonFilter(django_filters.FilterSet):
    statut = django_filters.CharFilter(field_name='statut_collecteur', lookup_expr='exact')
    gouvernorat = django_filters.CharFilter(field_name='gouvernorat', lookup_expr='icontains')
    date_debut = django_filters.DateFilter(field_name='date_ajout', lookup_expr='date__gte')
    date_fin = django_filters.DateFilter(field_name='date_ajout', lookup_expr='date__lte')
    recu_physiquement = django_filters.BooleanFilter(field_name='recu_physiquement')

    class Meta:
        model = Echantillon
        fields = ['statut', 'gouvernorat', 'date_debut', 'date_fin', 'recu_physiquement']
