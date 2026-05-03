from django.utils import timezone
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend

from .models import Echantillon
from .serializers import EchantillonSerializer
from .filters import EchantillonFilter
from users.models import User
from users.permissions import IsDirection, IsCollecteur, IsDegustateur


# Fields that are tracked in the edit history once a sample is physically received.
# Any change to these fields after recu_physiquement=True is recorded with old + new values.
TRACKED_FIELDS = [
    'variete', 'scellage', 'quantite_estimee',
    'gouvernorat', 'delegation', 'cite', 'remarques',
]


# ─────────────────────────────────────────────────────────────────────────────
# EchantillonViewSet
#
# Think of this as the RECEPTIONIST for the /api/echantillons/ endpoint.
# Every request that arrives at that URL comes through here.
#
# A ViewSet handles all 5 standard operations in one class:
#   GET    /api/echantillons/         → list()    — returns all samples the user can see
#   POST   /api/echantillons/         → create()  — adds a new sample
#   GET    /api/echantillons/<id>/    → retrieve() — returns one specific sample
#   PATCH  /api/echantillons/<id>/    → update()  — edits a sample
#   DELETE /api/echantillons/<id>/    → destroy() — deletes a sample
#
# Plus custom actions (decorated with @action) for specific business operations
# like approving a sample, confirming a purchase, etc.
# ─────────────────────────────────────────────────────────────────────────────
class EchantillonViewSet(viewsets.ModelViewSet):
    serializer_class = EchantillonSerializer

    # Every endpoint requires the user to be logged in.
    # If no valid JWT token is provided, Django returns 401 automatically.
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = EchantillonFilter
    search_fields = ['numero', 'reference_bouteille', 'variete', 'fournisseur__nom', 'fournisseur__code_fournisseur']
    ordering_fields = ['date_ajout', 'updated_at', 'statut_collecteur']
    ordering = ['-date_ajout']

    def get_queryset(self):
        # This method decides WHICH samples the logged-in user is allowed to see.
        # Each role sees a different subset:
        #
        #   - Laboratoire → only samples that have been physically received at the company
        #   - Collecteur  → only samples they personally registered
        #   - Direction / everyone else → all samples
        #
        # This runs automatically before every list() or retrieve() call.
        user = self.request.user
        qs = Echantillon.objects.select_related('fournisseur', 'collecteur').all()
        if user.role == User.Role.LABORATOIRE:
            qs = qs.filter(recu_physiquement=True)
        elif user.role == User.Role.COLLECTEUR:
            qs = qs.filter(collecteur=user)
        return qs.order_by('-date_ajout')

    def perform_create(self, serializer):
        # Called automatically when a POST request creates a new sample.
        # If the logged-in user is a collector, we attach them as the owner of the sample.
        # Flutter does NOT send the collecteur field — Django sets it here from the token.
        if self.request.user.role == User.Role.COLLECTEUR:
            serializer.save(collecteur=self.request.user)
        else:
            serializer.save()

    def perform_update(self, serializer):
        # Called automatically when a PATCH request edits a sample.
        #
        # If the sample has already been physically received (recu_physiquement=True),
        # any field change must be recorded in edit_history so all roles can see
        # what was changed, by whom, and when.
        #
        # If nothing in TRACKED_FIELDS changed, we skip the history entry and just save.
        obj = serializer.instance
        if obj.recu_physiquement:
            entry = {
                'horodatage': timezone.now().isoformat(),  # timestamp of the edit
                'modifie_par': str(self.request.user.id),  # who made the change
                'modifications': {},
            }
            for field in TRACKED_FIELDS:
                old_val = getattr(obj, field)
                new_val = serializer.validated_data.get(field, old_val)
                if old_val != new_val:
                    entry['modifications'][field] = {'avant': old_val, 'apres': new_val}
            if entry['modifications']:
                history = list(obj.edit_history)
                history.append(entry)
                serializer.save(edit_history=history)
                return
        serializer.save()

    def destroy(self, request, *args, **kwargs):
        # Called automatically when a DELETE request tries to remove a sample.
        # Business rules prevent deletion in two cases:
        #   1. The sample has already been physically received — it's in the system now
        #   2. The status has advanced past "réceptionné" — it's already in a workflow
        obj = self.get_object()
        if obj.recu_physiquement:
            return Response(
                {'detail': 'Impossible de supprimer un échantillon déjà reçu physiquement.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        if obj.statut_collecteur != Echantillon.StatutCollecteur.RECEPTIONNE:
            return Response(
                {'detail': 'Impossible de supprimer un échantillon dont le statut a avancé.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        return super().destroy(request, *args, **kwargs)

    # ── Custom actions ────────────────────────────────────────────────────────
    #
    # These are extra endpoints beyond the standard 5.
    # Each @action decorator creates a new URL automatically:
    #   PATCH /api/echantillons/<id>/confirmer_reception/
    #   PATCH /api/echantillons/<id>/approuver/
    #   etc.
    # ─────────────────────────────────────────────────────────────────────────

    @action(detail=True, methods=['patch'], permission_classes=[IsDegustateur])
    def confirmer_reception(self, request, pk=None):
        # The taster uses this to mark a sample as physically arrived at the company.
        # This locks the sample against deletion and starts the edit history tracking.
        obj = self.get_object()
        obj.recu_physiquement = True
        obj.date_arrivee_echantillon = timezone.now()
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch'], permission_classes=[IsDirection])
    def approuver(self, request, pk=None):
        # The CEO approves a sample for negotiation.
        # This moves the sample to "en_negociation" for both the CEO and the collector.
        # Optionally sets the negotiation budget and internal notes.
        obj = self.get_object()
        obj.statut_ceo = Echantillon.StatutCEO.EN_NEGOCIATION
        obj.statut_collecteur = Echantillon.StatutCollecteur.EN_NEGOCIATION
        if request.data.get('budget_negociation'):
            obj.budget_negociation = request.data['budget_negociation']
        if request.data.get('quantite_cible_t'):
            obj.quantite_cible_t = request.data['quantite_cible_t']
        if request.data.get('note_interne'):
            obj.note_interne = request.data['note_interne']
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch'], permission_classes=[IsDirection])
    def refuser(self, request, pk=None):
        # The CEO refuses a sample. Optionally records the reason for refusal.
        obj = self.get_object()
        obj.statut_ceo = Echantillon.StatutCEO.REFUSE
        obj.raison_refus = request.data.get('raison_refus', '')
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch'], permission_classes=[IsCollecteur])
    def confirmer_achat(self, request, pk=None):
        # The collector confirms the purchase after the CEO has approved negotiation.
        # Guards:
        #   - Only the collector who owns this sample can confirm it
        #   - The sample must be in "en_negociation" status
        # On success: sets the final price and reserved truck, moves to "achat_confirme".
        obj = self.get_object()
        if obj.collecteur != request.user:
            return Response({'detail': 'Not your sample.'}, status=status.HTTP_403_FORBIDDEN)
        if obj.statut_collecteur != Echantillon.StatutCollecteur.EN_NEGOCIATION:
            return Response(
                {'detail': 'Le statut doit être en_negociation.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        obj.statut_collecteur = Echantillon.StatutCollecteur.ACHAT_CONFIRME
        obj.statut_ceo = Echantillon.StatutCEO.ACHAT_CONFIRME
        if request.data.get('prix_final'):
            obj.prix_final = request.data['prix_final']
        if request.data.get('camion_reserve'):
            obj.camion_reserve = request.data['camion_reserve']
        obj.save()
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=False, methods=['post'], permission_classes=[IsCollecteur])
    def bulk(self, request):
        # Creates multiple samples in a single request.
        # The collector can register several bottles at once from the field.
        # Accepts either a plain list or { "echantillons": [...] }.
        # Returns the created samples and any errors separately.
        items = request.data if isinstance(request.data, list) else request.data.get('echantillons', [])
        if not items:
            return Response({'detail': 'Fournir une liste d\'échantillons.'}, status=status.HTTP_400_BAD_REQUEST)

        created, errors = [], []
        for i, item in enumerate(items):
            serializer = EchantillonSerializer(data=item, context={'request': request})
            if serializer.is_valid():
                obj = serializer.save(collecteur=request.user)
                created.append(EchantillonSerializer(obj, context={'request': request}).data)
            else:
                errors.append({'index': i, 'errors': serializer.errors})

        if errors and not created:
            return Response({'errors': errors}, status=status.HTTP_400_BAD_REQUEST)
        response_status = status.HTTP_201_CREATED if not errors else status.HTTP_207_MULTI_STATUS
        return Response({'created': created, 'errors': errors}, status=response_status)
