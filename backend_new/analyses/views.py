from django.db import transaction
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from echantillons.models import Echantillon
from users.permissions import IsChefDegustation, IsDegustateur, IsDirection, IsLaboratoire

from .models import AnalyseLabo
from .serializers import AnalyseLaboSerializer, LabEchantillonAnalyseSerializer


def _sync_echantillon_labo_status(analyse):
    if analyse.statut == AnalyseLabo.Statut.SOUMIS:
        statut = Echantillon.StatutLabo.SOUMIS
    else:
        statut = Echantillon.StatutLabo.EN_COURS
    Echantillon.objects.filter(pk=analyse.echantillon_id).update(statut_labo=statut)


class LabEchantillonListView(generics.ListAPIView):
    serializer_class = LabEchantillonAnalyseSerializer
    permission_classes = [IsLaboratoire | IsDirection | IsChefDegustation | IsDegustateur]

    def get_queryset(self):
        return (
            Echantillon.objects.filter(recu_physiquement=True)
            .select_related('fournisseur', 'collecteur', 'analyse', 'analyse__technicien')
            .order_by('-date_arrivee_echantillon', '-date_ajout')
        )


class AnalyseListCreateView(generics.ListCreateAPIView):
    serializer_class = AnalyseLaboSerializer
    permission_classes = [IsLaboratoire | IsDirection | IsChefDegustation | IsDegustateur]
    # Accept JSON (no photo) AND multipart (photo upload).
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsLaboratoire()]
        return super().get_permissions()

    def get_queryset(self):
        user = self.request.user
        if user.role == 'laboratoire':
            return (
                AnalyseLabo.objects.filter(echantillon__recu_physiquement=True)
                .select_related('echantillon', 'technicien')
                .order_by('-date_analyse')
            )
        # Direction and panel roles can see all analyses.
        return (
            AnalyseLabo.objects.all()
            .select_related('echantillon', 'technicien')
            .order_by('-date_analyse')
        )

    def perform_create(self, serializer):
        with transaction.atomic():
            analyse = serializer.save(technicien=self.request.user)
            _sync_echantillon_labo_status(analyse)


class AnalyseDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = AnalyseLaboSerializer
    permission_classes = [IsLaboratoire | IsDirection | IsChefDegustation | IsDegustateur]
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def get_permissions(self):
        if self.request.method in ('PUT', 'PATCH', 'DELETE'):
            return [IsLaboratoire()]
        return super().get_permissions()

    def get_queryset(self):
        queryset = AnalyseLabo.objects.select_related('echantillon', 'technicien')
        if self.request.user.role == 'laboratoire':
            queryset = queryset.filter(echantillon__recu_physiquement=True)
        return queryset

    def perform_update(self, serializer):
        if self.get_object().statut == AnalyseLabo.Statut.SOUMIS:
            raise ValidationError({'detail': 'Une analyse soumise ne peut plus etre modifiee.'})
        with transaction.atomic():
            analyse = serializer.save()
            _sync_echantillon_labo_status(analyse)

    def perform_destroy(self, instance):
        if instance.statut == AnalyseLabo.Statut.SOUMIS:
            raise ValidationError({'detail': 'Une analyse soumise ne peut plus etre supprimee.'})
        echantillon_id = instance.echantillon_id
        with transaction.atomic():
            instance.delete()
            Echantillon.objects.filter(pk=echantillon_id).update(
                statut_labo=Echantillon.StatutLabo.EN_ATTENTE
            )


class AnalyseSoumettreView(APIView):
    permission_classes = [IsLaboratoire]

    def post(self, request, pk):
        try:
            analyse = AnalyseLabo.objects.select_related('echantillon').get(
                pk=pk,
                technicien=request.user,
            )
        except AnalyseLabo.DoesNotExist:
            return Response(
                {'detail': 'Analyse introuvable.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if analyse.statut == 'soumis':
            return Response(
                {'detail': 'Analyse deja soumise.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            analyse.statut = AnalyseLabo.Statut.SOUMIS
            analyse.save()
            analyse.echantillon.statut_labo = Echantillon.StatutLabo.SOUMIS
            analyse.echantillon.save()

        return Response(AnalyseLaboSerializer(analyse, context={'request': request}).data)


