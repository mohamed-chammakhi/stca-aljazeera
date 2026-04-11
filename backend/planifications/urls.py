from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PlanificationArrivageViewSet, PlanificationLivraisonViewSet

router = DefaultRouter()
router.register(r'arrivage',  PlanificationArrivageViewSet,  basename='planif-arrivage')
router.register(r'livraison', PlanificationLivraisonViewSet, basename='planif-livraison')

urlpatterns = [path('', include(router.urls))]
