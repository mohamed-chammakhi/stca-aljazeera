from django.urls import path
from .views import (
    ChangePasswordView,
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
    path(
        'me/changer-mot-de-passe/',
        ChangePasswordView.as_view(),
        name='change-password',
    ),
    path('panel-members/', PanelMemberListView.as_view(), name='panel-members'),
    path('create/', UserCreateView.as_view(), name='user-create'),
    path('<uuid:pk>/', UserDetailView.as_view(), name='user-detail'),
    path('<uuid:pk>/toggle-active/', UserToggleActiveView.as_view(), name='user-toggle-active'),
]
