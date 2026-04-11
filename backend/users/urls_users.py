from django.urls import path
from .views import UserListCreateView, UserDetailView, me

urlpatterns = [
    path('',        UserListCreateView.as_view(), name='user-list-create'),
    path('me/',     me,                           name='user-me'),
    path('<uuid:pk>/', UserDetailView.as_view(),  name='user-detail'),
]
