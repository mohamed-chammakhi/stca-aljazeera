from django.urls import path
from .views import MessageListCreateView, MessageDetailView

# /api/messages/          → list all messages or send a new one
# /api/messages/<uuid>/   → get or delete one specific message
urlpatterns = [
    path('', MessageListCreateView.as_view(), name='message-list'),
    path('<uuid:pk>/', MessageDetailView.as_view(), name='message-detail'),
]
