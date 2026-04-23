from django.urls import path
from .views import UserListView, UserCreateView, UserDetailView, UserToggleActiveView, CurrentUserView

urlpatterns = [
    path('', UserListView.as_view(), name='user-list'),
    path('me/', CurrentUserView.as_view(), name='user-me'),
    path('create/', UserCreateView.as_view(), name='user-create'),
    path('<uuid:pk>/', UserDetailView.as_view(), name='user-detail'),
    path('<uuid:pk>/toggle-active/', UserToggleActiveView.as_view(), name='user-toggle-active'),
]
