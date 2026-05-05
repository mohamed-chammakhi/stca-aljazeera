from django.urls import path
from .views import SessionListCreateView, SessionDetailView, SessionApprouverView, SessionRefuserView, SessionConfirmerPresenceView

# /api/sessions/                           → list all sessions or create a new one
# /api/sessions/<uuid>/                    → get, edit, or delete one specific session
# /api/sessions/<uuid>/approuver/          → chef_panel approves a session
# /api/sessions/<uuid>/refuser/            → chef_panel refuses a session
# /api/sessions/<uuid>/confirmer_presence/ → participant confirms their attendance
urlpatterns = [
    path('', SessionListCreateView.as_view(), name='session-list'),
    path('<uuid:pk>/', SessionDetailView.as_view(), name='session-detail'),
    path('<uuid:pk>/approuver/', SessionApprouverView.as_view(), name='session-approuver'),
    path('<uuid:pk>/refuser/', SessionRefuserView.as_view(), name='session-refuser'),
    path('<uuid:pk>/confirmer_presence/', SessionConfirmerPresenceView.as_view(), name='session-confirmer-presence'),
]
