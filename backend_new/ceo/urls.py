from django.urls import path
from .views import CeoDashboardView

urlpatterns = [
    path('dashboard/', CeoDashboardView.as_view(), name='ceo-dashboard'),
]
