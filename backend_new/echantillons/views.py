import re
from datetime import datetime, time
from decimal import Decimal, InvalidOperation

from django.utils import timezone
from django.utils.dateparse import parse_date, parse_datetime
from django.db.models import Count
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.response import Response
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from core.ocr_service import extract_echantillon_from_image

from .models import Echantillon
from .serializers import EchantillonSerializer
from .filters import EchantillonFilter
from users.models import User
from users.permissions import IsChefPanel, IsDirection, IsCollecteur, IsDegustateur, IsLaboratoire
from notifications.models import Notification


# Fields that are tracked in the edit history once a sample is physically received.
# Any change to these fields after recu_physiquement=True is recorded with old + new values.
TRACKED_FIELDS = [
    'variete', 'scellage', 'quantite_estimee',
    'gouvernorat', 'delegation', 'cite', 'remarques',
]


def _decimal_from_display(value):
    if value in (None, ''):
        return None
    if isinstance(value, Decimal):
        return value
    text = str(value).replace(',', '.')
    match = re.search(r'-?\d+(?:\.\d+)?', text)
    if not match:
        raise ValidationError({'detail': f'Valeur numerique invalide: {value}'})
    try:
        return Decimal(match.group(0))
    except InvalidOperation:
        raise ValidationError({'detail': f'Valeur numerique invalide: {value}'})


def _datetime_from_payload(value):
    if value in (None, ''):
        return None
    if hasattr(value, 'isoformat'):
        return value
    parsed = parse_datetime(str(value))
    if parsed is None:
        parsed_date = parse_date(str(value))
        if parsed_date is not None:
            parsed = datetime.combine(parsed_date, time.min)
    if parsed is None:
        raise ValidationError({'detail': f'Date invalide: {value}'})
    if timezone.is_naive(parsed):
        parsed = timezone.make_aware(parsed, timezone.get_current_timezone())
    return parsed


def _format_decimal(value):
    if value is None:
        return '-'
    text = f"{value:.2f}"
    return text.rstrip('0').rstrip('.') if '.' in text else text


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
    # Accept JSON (normal CRUD) and multipart (sample create WITH a bottle photo).
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    # Every endpoint requires the user to be logged in.
    # If no valid JWT token is provided, Django returns 401 automatically.
    permission_classes = [IsCollecteur | IsDegustateur | IsDirection | IsChefPanel | IsLaboratoire]
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

    def get_permissions(self):
        if self.action in ['create', 'bulk', 'destroy']:
            return [IsCollecteur()]
        if self.action in ['update', 'partial_update']:
            return [(IsCollecteur | IsDegustateur)()]
        return super().get_permissions()

    def _store_bottle_photo(self):
        # If the collector attached a bottle photo (multipart 'image' field),
        # save it on the on-premise media storage and return its URL.
        # The photo is kept as proof the sample exists and so tasters can
        # visually tell bottles apart later.
        import os
        import uuid
        f = self.request.FILES.get('image')
        if not f:
            return None
        ext = os.path.splitext(f.name)[1].lower() or '.jpg'
        name = f"echantillons/{uuid.uuid4().hex}{ext}"
        saved = default_storage.save(name, ContentFile(f.read()))
        return default_storage.url(saved)

    def perform_create(self, serializer):
        # Called automatically when a POST request creates a new sample.
        # If the logged-in user is a collector, we attach them as the owner of the sample.
        # Flutter does NOT send the collecteur field — Django sets it here from the token.
        extra = {}
        photo_url = self._store_bottle_photo()
        if photo_url:
            extra['image_url'] = photo_url
        if self.request.user.role == User.Role.COLLECTEUR:
            serializer.save(
                collecteur=self.request.user,
                statut_collecteur=Echantillon.StatutCollecteur.RECEPTIONNE,
                **extra,
            )
        else:
            serializer.save(**extra)

    def perform_update(self, serializer):
        # Called automatically when a PATCH request edits a sample.
        #
        # If the sample has already been physically received (recu_physiquement=True),
        # any field change must be recorded in edit_history so all roles can see
        # what was changed, by whom, and when.
        #
        # If nothing in TRACKED_FIELDS changed, we skip the history entry and just save.
        obj = serializer.instance
        requested_status = serializer.validated_data.get('statut_collecteur')
        if (
            self.request.user.role == User.Role.COLLECTEUR
            and requested_status is not None
            and requested_status != obj.statut_collecteur
        ):
            raise ValidationError(
                {'statut_collecteur': ['Utilisez l action dediee pour changer le statut.']}
            )
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

    def _confirmer_reception(self, request):
        # The taster uses this to mark a sample as physically arrived at the company.
        # This locks the sample against deletion and starts the edit history tracking.
        obj = self.get_object()
        if not obj.recu_physiquement:
            obj.recu_physiquement = True
            obj.date_arrivee_echantillon = timezone.now()
            obj.save(update_fields=['recu_physiquement', 'date_arrivee_echantillon', 'updated_at'])
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['patch', 'post'], permission_classes=[IsDegustateur | IsChefPanel])
    def confirmer_reception(self, request, pk=None):
        return self._confirmer_reception(request)

    @action(detail=True, methods=['post', 'patch'], permission_classes=[IsDegustateur | IsChefPanel], url_path='confirmer-reception')
    def confirmer_reception_hyphen(self, request, pk=None):
        return self._confirmer_reception(request)

    @action(detail=True, methods=['patch'], permission_classes=[IsDirection])
    def approuver(self, request, pk=None):
        # The CEO approves a sample for negotiation.
        # This moves the sample to "en_negociation" for both the CEO and the collector.
        # Optionally sets the negotiation budget and internal notes.
        obj = self.get_object()
        obj.statut_ceo = Echantillon.StatutCEO.EN_NEGOCIATION
        obj.statut_collecteur = Echantillon.StatutCollecteur.EN_NEGOCIATION
        if request.data.get('budget_negociation'):
            obj.budget_negociation = _decimal_from_display(request.data['budget_negociation'])
        if request.data.get('quantite_cible_t'):
            obj.quantite_cible_t = _decimal_from_display(request.data['quantite_cible_t'])
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

    def _notify_purchase_proposal(self, obj):
        recipients = User.objects.filter(role=User.Role.DIRECTION, is_active=True)
        price = f"{_format_decimal(obj.budget_negociation)} TND/L"
        quantity = _format_decimal(obj.quantite_cible_t) if obj.quantite_cible_t is not None else (obj.quantite_estimee or '-')
        ref = obj.reference_bouteille or obj.numero
        collector = f"{obj.collecteur.prenom} {obj.collecteur.nom}" if obj.collecteur else '-'
        notifications = [
            Notification(
                destinataire=user,
                type=Notification.Type.PROPOSITION_ACHAT_ATTENTE,
                titre="Proposition d'achat en attente",
                message=f"{ref} ({quantity} T) : {collector} propose {price}. A valider.",
                echantillon=obj,
                section=Notification.Section.ACHATS_VALIDATION,
            )
            for user in recipients
        ]
        if notifications:
            Notification.objects.bulk_create(notifications)

    def _apply_purchase_payload(self, obj, request):
        price = request.data.get('budget_negociation') or request.data.get('prix_final')
        if price:
            obj.budget_negociation = _decimal_from_display(price)
        if request.data.get('prix_final'):
            obj.prix_final = _decimal_from_display(request.data['prix_final'])
        if request.data.get('quantite_cible_t'):
            obj.quantite_cible_t = _decimal_from_display(request.data['quantite_cible_t'])
        if request.data.get('camion_reserve'):
            obj.camion_reserve = request.data['camion_reserve']
        if request.data.get('scellage'):
            obj.scellage = request.data['scellage']
        if request.data.get('date_livraison_stock'):
            obj.date_livraison_stock = _datetime_from_payload(request.data['date_livraison_stock'])
        if request.data.get('date_livraison_stock_fin'):
            obj.date_livraison_stock_fin = _datetime_from_payload(request.data['date_livraison_stock_fin'])

    def _submit_purchase_proposal(self, request):
        obj = self.get_object()
        if obj.collecteur != request.user:
            return Response({'detail': 'Not your sample.'}, status=status.HTTP_403_FORBIDDEN)
        if obj.statut_collecteur != Echantillon.StatutCollecteur.EN_NEGOCIATION:
            return Response(
                {'detail': 'Le statut doit etre en_negociation.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        self._apply_purchase_payload(obj, request)
        obj.statut_collecteur = Echantillon.StatutCollecteur.EN_NEGOCIATION
        obj.statut_ceo = Echantillon.StatutCEO.EN_NEGOCIATION
        obj.save()
        self._notify_purchase_proposal(obj)
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    def _confirm_purchase_proposal(self, request):
        obj = self.get_object()
        if obj.statut_ceo != Echantillon.StatutCEO.EN_NEGOCIATION or obj.budget_negociation is None:
            return Response(
                {'detail': 'Aucune proposition d achat en attente pour cet echantillon.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        obj.statut_collecteur = Echantillon.StatutCollecteur.ACHAT_CONFIRME
        obj.statut_ceo = Echantillon.StatutCEO.ACHAT_CONFIRME
        obj.stock_arrive = False
        obj.save(update_fields=['statut_collecteur', 'statut_ceo', 'stock_arrive', 'updated_at'])
        return Response(EchantillonSerializer(obj, context={'request': request}).data)

    def _confirmer_achat(self, request):
        if request.user.role == User.Role.DIRECTION:
            return self._confirm_purchase_proposal(request)
        return self._submit_purchase_proposal(request)
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

    @action(detail=True, methods=['patch', 'post'], permission_classes=[IsCollecteur | IsDirection])
    def confirmer_achat(self, request, pk=None):
        return self._confirmer_achat(request)

    @action(detail=True, methods=['post', 'patch'], permission_classes=[IsCollecteur | IsDirection], url_path='confirmer-achat')
    def confirmer_achat_hyphen(self, request, pk=None):
        return self._confirmer_achat(request)

    @action(detail=True, methods=['post'], permission_classes=[IsDirection], url_path='refuser-achat')
    def refuser_achat(self, request, pk=None):
        obj = self.get_object()
        raison = request.data.get('raison_refus', '').strip()
        if not raison:
            return Response(
                {'raison_refus': ['La raison du refus est obligatoire.']},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if obj.statut_ceo != Echantillon.StatutCEO.EN_NEGOCIATION or obj.budget_negociation is None:
            return Response(
                {'detail': 'Aucune proposition d achat en attente pour cet echantillon.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        obj.statut_ceo = Echantillon.StatutCEO.REFUSE
        obj.raison_refus = raison
        obj.save(update_fields=['statut_ceo', 'raison_refus', 'updated_at'])
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


class EchantillonOCRView(APIView):
    permission_classes = [IsCollecteur]
    parser_classes = [MultiPartParser]

    def post(self, request):
        image_file = request.FILES.get('image')
        if not image_file:
            return Response({'detail': 'Champ image requis.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            result = extract_echantillon_from_image(image_file.read(), content_type=image_file.content_type or 'image/jpeg')
            return Response(result)
        except EnvironmentError as e:
            return Response({'detail': str(e)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({'detail': f'Erreur OCR: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CollecteurCarteView(APIView):
    """
    GET /api/echantillons/collecteur/carte/
    Returns a summary of this collector's samples grouped by gouvernorat + delegation.
    Used to populate the map view in the Flutter app.
    """
    permission_classes = [IsCollecteur]

    def get(self, request):
        delegations = (
            Echantillon.objects
            .filter(collecteur=request.user)
            .values('gouvernorat', 'delegation')
            .annotate(nb_echantillons=Count('id'))
            .order_by('gouvernorat', 'delegation')
        )
        return Response({'delegations': list(delegations)})
