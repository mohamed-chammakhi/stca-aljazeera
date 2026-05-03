from django.urls import path
from .views import DegustateurDelaiView, DegustateurActiviteView

urlpatterns = [
    path('dashboard/delai/', DegustateurDelaiView.as_view(), name='deg-delai'),
    path('activite/', DegustateurActiviteView.as_view(), name='deg-activite'),
]
