from rest_framework.routers import DefaultRouter
from .views import EchantillonViewSet

router = DefaultRouter()
router.register(r'', EchantillonViewSet, basename='echantillon')

urlpatterns = router.urls
