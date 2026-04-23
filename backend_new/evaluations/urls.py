from django.urls import path
from .views import EvaluationListCreateView, EvaluationDetailView

urlpatterns = [
    path('', EvaluationListCreateView.as_view(), name='evaluation-list'),
    path('<uuid:pk>/', EvaluationDetailView.as_view(), name='evaluation-detail'),
]