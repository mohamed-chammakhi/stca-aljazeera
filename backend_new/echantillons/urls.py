from django.urls import path
from .views import EchantillonListCreateView, EchantillonDetailView

urlpatterns = [
    path('', EchantillonListCreateView.as_view(), name='echantillon-list'),
    path('<uuid:pk>/', EchantillonDetailView.as_view(), name='echantillon-detail'),
]
