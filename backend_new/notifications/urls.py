from django.urls import path
from .views import (
    NotificationListView,
    NotificationMarkReadView,
    NotificationMarkAllReadView,
    NotificationUnreadCountView,
    UrgentAnalysisRequestView,
    UrgentEvaluationRequestView,
)

urlpatterns = [
    path('', NotificationListView.as_view(), name='notification-list'),
    path('unread-count/', NotificationUnreadCountView.as_view(), name='notification-unread-count'),
    path('non-lus/', NotificationUnreadCountView.as_view(), name='notification-non-lus'),
    path('read-all/', NotificationMarkAllReadView.as_view(), name='notification-read-all'),
    path('lire-tout/', NotificationMarkAllReadView.as_view(), name='notification-lire-tout'),
    path('analyse-urgente/', UrgentAnalysisRequestView.as_view(), name='analyse-urgente'),
    path('evaluation-urgente/', UrgentEvaluationRequestView.as_view(), name='evaluation-urgente'),
    path('<uuid:pk>/lire/', NotificationMarkReadView.as_view(), name='notification-lire'),
    path('<uuid:pk>/', NotificationMarkReadView.as_view(), name='notification-detail'),
]
