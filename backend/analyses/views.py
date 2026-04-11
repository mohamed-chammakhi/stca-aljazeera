from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
import django_filters

from .models import AnalyseLabo
from .serializers import AnalyseLaboSerializer
from users.permissions import IsLaboratoire
from users.models import Role


class AnalyseFilter(django_filters.FilterSet):
    echantillon_id = django_filters.UUIDFilter(field_name='echantillon__id')
    technicien_id  = django_filters.UUIDFilter(field_name='technicien__id')

    class Meta:
        model  = AnalyseLabo
        fields = ['statut', 'priorite', 'echantillon_id', 'technicien_id']


class AnalyseLaboViewSet(viewsets.ModelViewSet):
    """
    GET   /api/analyses/         — Lab + Direction + Tasters.
    POST  /api/analyses/         — Lab technicians only.
    PATCH /api/analyses/<id>/    — Lab technician who owns it, or Direction.
    """
    serializer_class   = AnalyseLaboSerializer
    filter_backends    = [DjangoFilterBackend]
    filterset_class    = AnalyseFilter
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = AnalyseLabo.objects.select_related('echantillon', 'technicien').prefetch_related('criteres').all()
        # Collectors do not see lab analyses.
        if user.role == Role.COLLECTEUR:
            return qs.none()
        return qs

    def perform_create(self, serializer):
        user = self.request.user
        if user.role != Role.LABORATOIRE:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Only lab technicians can create analyses.')
        serializer.save(technicien=user)

    def check_object_permissions(self, request, obj):
        super().check_object_permissions(request, obj)
        user = request.user
        if request.method in ('PUT', 'PATCH', 'DELETE'):
            if user.role == Role.LABORATOIRE and obj.technicien != user:
                self.permission_denied(request, message='Not your analysis.')
            if user.role not in (Role.LABORATOIRE, Role.DIRECTION):
                self.permission_denied(request)

    @action(detail=True, methods=['post'], permission_classes=[IsLaboratoire])
    def submit(self, request, pk=None):
        """POST /api/analyses/<id>/submit/ — Mark analysis as soumis."""
        analyse = self.get_object()
        from echantillons.models import StatutLabo
        analyse.statut       = StatutLabo.SOUMIS
        analyse.submitted_at = timezone.now()
        analyse.save()

        # Also update the echantillon's statut_labo.
        analyse.echantillon.statut_labo = StatutLabo.SOUMIS
        analyse.echantillon.save(update_fields=['statut_labo'])

        return Response(AnalyseLaboSerializer(analyse, context={'request': request}).data)
