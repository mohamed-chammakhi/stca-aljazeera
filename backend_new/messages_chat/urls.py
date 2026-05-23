from django.urls import path
from .views import MessageDetailView, MessageListCreateView, MessageMarkReadView

# /api/messages/          → list all messages or send a new one
# /api/messages/<uuid>/   → get or delete one specific message
urlpatterns = [
    path('', MessageListCreateView.as_view(), name='message-list'),
    path('<uuid:pk>/lire/', MessageMarkReadView.as_view(), name='message-lire'),
    path('<uuid:pk>/', MessageDetailView.as_view(), name='message-detail'),
]
