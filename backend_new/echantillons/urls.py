from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import EchantillonViewSet, CollecteurCarteView

# The carte endpoint must come BEFORE the router urls so it isn't captured as a UUID pk.
urlpatterns = [
    path('collecteur/carte/', CollecteurCarteView.as_view(), name='collecteur-carte'),
]

router = DefaultRouter()
router.register(r'', EchantillonViewSet, basename='echantillon')

urlpatterns += router.urls
