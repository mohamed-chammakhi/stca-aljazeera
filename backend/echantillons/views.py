from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
import django_filters

from .models import Echantillon, StatutCollecteur, StatutCeo
from .serializers import EchantillonSerializer
from users.permissions import IsDirection, IsCollecteur, IsDegustateur
from users.models import Role


class EchantillonFilter(django_filters.FilterSet):
    statut_collecteur  = django_filters.CharFilter()
    statut_degustateur = django_filters.CharFilter()
    statut_labo        = django_filters.CharFilter()
    statut_ceo         = django_filters.CharFilter()
    collecteur_id      = django_filters.UUIDFilter(field_name='collecteur__id')
    fournisseur_id     = django_filters.UUIDFilter(field_name='fournisseur__id')
    date_from          = django_filters.DateFilter(field_name='date_ajout', lookup_expr='gte')
    date_to            = django_filters.DateFilter(field_name='date_ajout', lookup_expr='lte')
    recu_physiquement  = django_filters.BooleanFilter()

    class Meta:
        model  = Echantillon
        fields = [
            'statut_collecteur', 'statut_degustateur', 'statut_labo',
            'statut_ceo', 'collecteur_id', 'fournisseur_id',
            'recu_physiquement', 'gouvernorat',
        ]


class EchantillonViewSet(viewsets.ModelViewSet):
    """
    Full CRUD on echantillons with role-based access control.

    - Collector : can only edit/delete their own samples in 'receptionne' status.
    - Taster    : can update any sample (to toggle recu_physiquement or set statut_degustateur).
    - Direction : can update statut_ceo, budget_negociation, etc.
    - Lab       : read-only access filtered to physically-received samples.
    """
    serializer_class = EchantillonSerializer
    filter_backends  = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class  = EchantillonFilter
    search_fields    = ['ref', 'reference_bouteille', 'gouvernorat', 'variete']
    ordering_fields  = ['date_ajout', 'ref', 'statut_collecteur']
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = Echantillon.objects.select_related('fournisseur', 'collecteur').all()

        # Lab technicians only see physically-received samples.
        if user.role == Role.LABORATOIRE:
            qs = qs.filter(recu_physiquement=True)

        return qs

    def perform_create(self, serializer):
        # Auto-assign the logged-in user as collecteur if they are a collector
        # and no collecteur was explicitly provided.
        user = self.request.user
        if user.role == Role.COLLECTEUR:
            serializer.save(collecteur=user)
        else:
            serializer.save()

    def check_object_permissions(self, request, obj):
        super().check_object_permissions(request, obj)
        user = request.user

        if request.method in ('PUT', 'PATCH', 'DELETE'):
            # Collector can only modify/delete their own samples in receptionne status.
            if user.role == Role.COLLECTEUR:
                if obj.collecteur != user:
                    self.permission_denied(request, message='Not your sample.')
                if request.method == 'DELETE' and obj.statut_collecteur != StatutCollecteur.RECEPTIONNE:
                    self.permission_denied(request, message='Cannot delete a sample past receptionne status.')

            # Lab technicians are read-only.
            if user.role == Role.LABORATOIRE:
                self.permission_denied(request, message='Lab technicians have read-only access.')

    # ── Custom actions ────────────────────────────────────────────────────────

    @action(detail=True, methods=['patch'], permission_classes=[IsDirection])
    def approve(self, request, pk=None):
        """PATCH /api/echantillons/<id>/approve/ — Direction sets en_negociation."""
        obj = self.get_object()
        budget   = request.data.get('budget_negociation')
        quantite = request.data.get('quantite_cible_t')
        date_liv = request.data.get('date_livraison_stock')

        obj.statut_ceo        = StatutCeo.EN_NEGOCIATION
        obj.statut_collecteur = StatutCollecteur.EN_NEGOCIATION
        if budget:   obj.budget_negociation   = budget
        if quantite: obj.quantite_cible_t     = quantite
        if date_liv: obj.date_livraison_stock = date_liv
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch'], permission_classes=[IsDirection])
    def reject(self, request, pk=None):
        """PATCH /api/echantillons/<id>/reject/ — Direction sets refusé."""
        obj = self.get_object()
        obj.statut_ceo   = StatutCeo.REFUSE
        obj.raison_refus = request.data.get('raison_refus', '')
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch'], permission_classes=[IsDegustateur])
    def confirm_reception(self, request, pk=None):
        """PATCH /api/echantillons/<id>/confirm_reception/ — Taster marks physical arrival."""
        obj = self.get_object()
        from django.utils import timezone
        obj.recu_physiquement        = True
        obj.date_arrivee_echantillon = timezone.now()
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch'], permission_classes=[IsCollecteur])
    def confirm_purchase(self, request, pk=None):
        """PATCH /api/echantillons/<id>/confirm_purchase/ — Collector confirms purchase."""
        obj = self.get_object()
        if obj.collecteur != request.user:
            return Response({'detail': 'Not your sample.'}, status=status.HTTP_403_FORBIDDEN)
        if obj.statut_collecteur != StatutCollecteur.EN_NEGOCIATION:
            return Response({'detail': 'Sample is not in en_negociation status.'}, status=status.HTTP_400_BAD_REQUEST)

        obj.statut_collecteur = StatutCollecteur.ACHAT_CONFIRME
        obj.statut_ceo        = StatutCeo.ACHAT_CONFIRME
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)
