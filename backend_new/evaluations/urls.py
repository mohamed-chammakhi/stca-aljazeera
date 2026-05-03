from django.urls import path
from .views import EvaluationListCreateView, EvaluationDetailView, EvaluationSoumettreView

urlpatterns = [
    path('', EvaluationListCreateView.as_view(), name='evaluation-list'),
    path('<uuid:pk>/', EvaluationDetailView.as_view(), name='evaluation-detail'),
    path('<uuid:pk>/soumettre/', EvaluationSoumettreView.as_view(), name='evaluation-soumettre'),
]