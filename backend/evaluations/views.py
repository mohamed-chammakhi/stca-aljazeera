from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
import django_filters

from .models import EvaluationOrganoleptique
from .serializers import EvaluationOrganoleptiqueSérializer
from users.permissions import IsDegustateur
from users.models import Role


class EvaluationFilter(django_filters.FilterSet):
    echantillon_id = django_filters.UUIDFilter(field_name='echantillon__id')
    tasteur_id     = django_filters.UUIDFilter(field_name='tasteur__id')
    session_id     = django_filters.UUIDFilter(field_name='session__id')

    class Meta:
        model  = EvaluationOrganoleptique
        fields = ['echantillon_id', 'tasteur_id', 'session_id', 'classification']


class EvaluationViewSet(viewsets.ModelViewSet):
    """
    GET  /api/evaluations/         — Direction + Tasters see all; others forbidden.
    POST /api/evaluations/         — Tasters only.
    PATCH /api/evaluations/<id>/   — Taster who created it, or Direction.
    """
    serializer_class = EvaluationOrganoleptiqueSérializer
    filter_backends  = [DjangoFilterBackend]
    filterset_class  = EvaluationFilter
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs = EvaluationOrganoleptique.objects.select_related('echantillon', 'tasteur', 'session').all()
        # Collectors and lab technicians do not see evaluations.
        if user.role in (Role.COLLECTEUR, Role.LABORATOIRE):
            return qs.none()
        return qs

    def perform_create(self, serializer):
        user = self.request.user
        if user.role != Role.DEGUSTATEUR:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Only tasters can submit evaluations.')
        serializer.save(tasteur=user)

    def check_object_permissions(self, request, obj):
        super().check_object_permissions(request, obj)
        user = request.user
        if request.method in ('PUT', 'PATCH', 'DELETE'):
            if user.role == Role.DEGUSTATEUR and obj.tasteur != user:
                self.permission_denied(request, message='You can only modify your own evaluations.')
            if user.role not in (Role.DEGUSTATEUR, Role.DIRECTION):
                self.permission_denied(request)
