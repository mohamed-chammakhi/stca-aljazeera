from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import (
    CollecteurCarteView,
    EchantillonOcrStatusView,
    EchantillonOcrView,
    EchantillonViewSet,
)

# Non-router endpoints must come BEFORE the router urls so they aren't captured as UUID pks.
urlpatterns = [
    path('collecteur/carte/', CollecteurCarteView.as_view(), name='collecteur-carte'),
    path('ocr/', EchantillonOcrView.as_view(), name='echantillon-ocr'),
    path('ocr/statut/', EchantillonOcrStatusView.as_view(), name='echantillon-ocr-statut'),
]

router = DefaultRouter()
router.register(r'', EchantillonViewSet, basename='echantillon')

urlpatterns += router.urls
