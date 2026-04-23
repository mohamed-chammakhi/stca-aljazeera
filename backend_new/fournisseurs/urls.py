from django.urls import path
from .views import FournisseurListCreateView, FournisseurDetailView 
urlpatterns = [
    path('', FournisseurListCreateView.as_view(), name='fournisseur-list'),
    path('<uuid:pk>/', FournisseurDetailView.as_view(), name='fournisseur-detail'),
    
]