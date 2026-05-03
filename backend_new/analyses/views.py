import io

from django.db import transaction
from django.http import FileResponse
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from rest_framework import generics, status
from rest_framework.parsers import MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from core.ocr_service import extract_analyse_from_image

from .models import AnalyseLabo
from .serializers import AnalyseLaboSerializer


class AnalyseListCreateView(generics.ListCreateAPIView):
    serializer_class = AnalyseLaboSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'laboratoire':
            return AnalyseLabo.objects.filter(technicien=user).order_by('-date_analyse')
        # Direction and chef_panel can see all analyses
        return AnalyseLabo.objects.all().order_by('-date_analyse')

    def perform_create(self, serializer):
        serializer.save(technicien=self.request.user)


class AnalyseDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = AnalyseLabo.objects.all()
    serializer_class = AnalyseLaboSerializer
    permission_classes = [IsAuthenticated]


class AnalyseSoumettreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            analyse = AnalyseLabo.objects.select_related('echantillon').get(
                pk=pk, technicien=request.user
            )
        except AnalyseLabo.DoesNotExist:
            return Response({'detail': 'Analyse introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        if analyse.statut == 'soumis':
            return Response({'detail': 'Analyse déjà soumise.'}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            analyse.statut = 'soumis'
            analyse.save()
            analyse.echantillon.statut_labo = 'soumis'
            analyse.echantillon.save()

        return Response(AnalyseLaboSerializer(analyse, context={'request': request}).data)


class AnalyseExportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            qs = AnalyseLabo.objects.select_related('echantillon', 'technicien')
            if request.user.role == 'laboratoire':
                analyse = qs.get(pk=pk, technicien=request.user)
            else:
                analyse = qs.get(pk=pk)
        except AnalyseLabo.DoesNotExist:
            return Response({'detail': 'Analyse introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        buffer = io.BytesIO()
        p = canvas.Canvas(buffer, pagesize=A4)
        p.setFont("Helvetica-Bold", 16)
        p.drawString(50, 800, f"Rapport d'Analyse — {analyse.echantillon.numero}")
        p.setFont("Helvetica", 12)
        y = 760
        fields = [
            ('Acidité (%)', analyse.acidite),
            ('Indice de peroxyde', analyse.indice_peroxyde),
            ('K232', analyse.k232),
            ('K270', analyse.k270),
            ('ΔK', analyse.delta_k),
            ('Humidité (%)', analyse.humidite),
            ('Impuretés (%)', analyse.impuretes),
        ]
        for label, value in fields:
            display = str(value) if value is not None else 'N/A'
            p.drawString(50, y, f"{label}: {display}")
            y -= 22
        p.drawString(50, y - 10, f"Statut: {analyse.statut}")
        p.drawString(50, y - 30, f"Date d'analyse: {analyse.date_analyse.strftime('%d/%m/%Y')}")
        if analyse.technicien:
            p.drawString(50, y - 50, f"Technicien: {analyse.technicien.prenom} {analyse.technicien.nom}")
        p.showPage()
        p.save()
        buffer.seek(0)
        filename = f"analyse_{analyse.echantillon.numero}.pdf"
        return FileResponse(buffer, as_attachment=True, filename=filename, content_type='application/pdf')


class AnalyseOCRView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser]

    def post(self, request):
        image_file = request.FILES.get('image')
        if not image_file:
            return Response({'detail': 'Champ image requis.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            result = extract_analyse_from_image(image_file.read(), content_type=image_file.content_type or 'image/jpeg')
            return Response(result)
        except EnvironmentError as e:
            return Response({'detail': str(e)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({'detail': f'Erreur OCR: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
