from django.urls import path

from .views import (
    AnalyseDetailView,
    AnalyseListCreateView,
    AnalyseSoumettreView,
    LabEchantillonListView,
)

urlpatterns = [
    path('', AnalyseListCreateView.as_view(), name='analyse-list'),
    path('echantillons/', LabEchantillonListView.as_view(), name='analyse-echantillon-list'),
    path('<uuid:pk>/', AnalyseDetailView.as_view(), name='analyse-detail'),
    path('<uuid:pk>/soumettre/', AnalyseSoumettreView.as_view(), name='analyse-soumettre'),
]
