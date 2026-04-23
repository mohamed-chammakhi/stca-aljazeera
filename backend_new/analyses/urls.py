from django.urls import path
from .views import AnalyseListCreateView, AnalyseDetailView

urlpatterns = [
    path('', AnalyseListCreateView.as_view(), name='analyse-list'),
    path('<uuid:pk>/', AnalyseDetailView.as_view(), name='analyse-detail'),
]
