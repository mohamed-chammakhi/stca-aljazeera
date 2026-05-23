from django.urls import path
from .views import UserListCreateView, UserCreateView, UserDetailView, UserToggleActiveView, CurrentUserView

urlpatterns = [
    path('', UserListCreateView.as_view(), name='user-list'),
    path('me/', CurrentUserView.as_view(), name='user-me'),
    path('create/', UserCreateView.as_view(), name='user-create'),
    path('<uuid:pk>/', UserDetailView.as_view(), name='user-detail'),
    path('<uuid:pk>/toggle-active/', UserToggleActiveView.as_view(), name='user-toggle-active'),
]
