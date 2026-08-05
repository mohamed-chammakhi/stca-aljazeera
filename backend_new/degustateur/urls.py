from django.urls import path
from .views import (
    DegustateurActiviteView,
    DegustateurClassificationsView,
    DegustateurDelaiView,
    DegustateurPipelineView,
    DegustateurPresenceView,
    DegustateurUrgentesView,
)

urlpatterns = [
    path('dashboard/pipeline/', DegustateurPipelineView.as_view(), name='deg-pipeline'),
    path('dashboard/urgentes/', DegustateurUrgentesView.as_view(), name='deg-urgentes'),
    path(
        'dashboard/classifications/',
        DegustateurClassificationsView.as_view(),
        name='deg-classifications',
    ),
    path('dashboard/presence/', DegustateurPresenceView.as_view(), name='deg-presence'),
    path('dashboard/delai/', DegustateurDelaiView.as_view(), name='deg-delai'),
    path('activite/', DegustateurActiviteView.as_view(), name='deg-activite'),
]
