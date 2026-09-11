from django.urls import path
from .views import (
    MessageContactsView,
    MessageDetailView,
    MessageListCreateView,
    MessageMarkReadView,
    MessageUnreadCountView,
)

# /api/messages/          → list all messages or send a new one
# /api/messages/<uuid>/   → get or delete one specific message
urlpatterns = [
    path('', MessageListCreateView.as_view(), name='message-list'),
    path('contacts/', MessageContactsView.as_view(), name='message-contacts'),
    path('non-lus/', MessageUnreadCountView.as_view(), name='message-non-lus'),
    path('<uuid:pk>/lire/', MessageMarkReadView.as_view(), name='message-lire'),
    path('<uuid:pk>/', MessageDetailView.as_view(), name='message-detail'),
]
