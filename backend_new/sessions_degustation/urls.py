from django.urls import path
from .views import SessionListCreateView, SessionDetailView

# /api/sessions/          → list all sessions or create a new one
# /api/sessions/<uuid>/   → get, edit, or delete one specific session
urlpatterns = [
    path('', SessionListCreateView.as_view(), name='session-list'),
    path('<uuid:pk>/', SessionDetailView.as_view(), name='session-detail'),
]
