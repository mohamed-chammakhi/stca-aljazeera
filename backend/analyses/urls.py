from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AnalyseLaboViewSet

router = DefaultRouter()
router.register(r'', AnalyseLaboViewSet, basename='analyse')

urlpatterns = [path('', include(router.urls))]
