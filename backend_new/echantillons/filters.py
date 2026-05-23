import django_filters
from django.db.models import Q

from .models import Echantillon


class EchantillonFilter(django_filters.FilterSet):
    statut = django_filters.CharFilter(method='filter_statut')
    statut__in = django_filters.CharFilter(method='filter_statut_in')
    proposition_soumise = django_filters.BooleanFilter(method='filter_proposition_soumise')
    gouvernorat = django_filters.CharFilter(field_name='gouvernorat', lookup_expr='icontains')
    date_debut = django_filters.DateFilter(field_name='date_ajout', lookup_expr='date__gte')
    date_fin = django_filters.DateFilter(field_name='date_ajout', lookup_expr='date__lte')
    recu_physiquement = django_filters.BooleanFilter(field_name='recu_physiquement')

    class Meta:
        model = Echantillon
        fields = [
            'statut',
            'statut__in',
            'proposition_soumise',
            'gouvernorat',
            'date_debut',
            'date_fin',
            'recu_physiquement',
        ]

    def _status_query(self, value):
        collector_values = {choice[0] for choice in Echantillon.StatutCollecteur.choices}
        ceo_values = {choice[0] for choice in Echantillon.StatutCEO.choices}
        role = getattr(getattr(self, 'request', None), 'user', None)
        role = getattr(role, 'role', None)

        if role == 'direction' and value in ceo_values:
            return Q(statut_ceo=value)

        query = Q()
        if value in collector_values:
            query |= Q(statut_collecteur=value)
        if value in ceo_values:
            query |= Q(statut_ceo=value)
        if not query:
            query = Q(statut_collecteur=value)
        return query

    def filter_statut(self, queryset, name, value):
        return queryset.filter(self._status_query(value))

    def filter_statut_in(self, queryset, name, value):
        values = [item.strip() for item in value.split(',') if item.strip()]
        if not values:
            return queryset
        query = Q()
        for item in values:
            query |= self._status_query(item)
        return queryset.filter(query)

    def filter_proposition_soumise(self, queryset, name, value):
        if value:
            return queryset.filter(budget_negociation__isnull=False)
        return queryset.filter(budget_negociation__isnull=True)
