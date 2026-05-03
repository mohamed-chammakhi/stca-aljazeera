from django.urls import path
from .views import (
    AnalyseListCreateView,
    AnalyseDetailView,
    AnalyseSoumettreView,
    AnalyseExportView,
    AnalyseOCRView,
)

urlpatterns = [
    path('', AnalyseListCreateView.as_view(), name='analyse-list'),
    path('ocr/', AnalyseOCRView.as_view(), name='analyse-ocr'),
    path('<uuid:pk>/', AnalyseDetailView.as_view(), name='analyse-detail'),
    path('<uuid:pk>/soumettre/', AnalyseSoumettreView.as_view(), name='analyse-soumettre'),
    path('<uuid:pk>/export/', AnalyseExportView.as_view(), name='analyse-export'),
]
