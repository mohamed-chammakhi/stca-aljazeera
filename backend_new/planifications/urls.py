from django.urls import path
from .views import (
    ArrivageListCreateView, ArrivageDetailView,
    LivraisonListCreateView, LivraisonDetailView,
)

urlpatterns = [
    path('arrivage/', ArrivageListCreateView.as_view(), name='arrivage-list'),
    path('arrivage/<uuid:pk>/', ArrivageDetailView.as_view(), name='arrivage-detail'),
    path('livraison/', LivraisonListCreateView.as_view(), name='livraison-list'),
    path('livraison/<uuid:pk>/', LivraisonDetailView.as_view(), name='livraison-detail'),
]
