from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EchantillonViewSet

router = DefaultRouter()
router.register(r'', EchantillonViewSet, basename='echantillon')

urlpatterns = [path('', include(router.urls))]
