from django.urls import path
from .views import (
    CurrentUserView,
    PanelMemberListView,
    UserCreateView,
    UserDetailView,
    UserListCreateView,
    UserToggleActiveView,
)

urlpatterns = [
    path('', UserListCreateView.as_view(), name='user-list'),
    path('me/', CurrentUserView.as_view(), name='user-me'),
    path('panel-members/', PanelMemberListView.as_view(), name='panel-members'),
    path('create/', UserCreateView.as_view(), name='user-create'),
    path('<uuid:pk>/', UserDetailView.as_view(), name='user-detail'),
    path('<uuid:pk>/toggle-active/', UserToggleActiveView.as_view(), name='user-toggle-active'),
]
