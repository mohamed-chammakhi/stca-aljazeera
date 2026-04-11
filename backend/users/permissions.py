from rest_framework.permissions import BasePermission
from .models import Role


class IsDirection(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == Role.DIRECTION


class IsCollecteur(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == Role.COLLECTEUR


class IsDegustateur(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == Role.DEGUSTATEUR


class IsLaboratoire(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == Role.LABORATOIRE


class IsDirectionOrReadOnly(BasePermission):
    """Direction can do anything; other authenticated users can only read."""
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        if request.method in ('GET', 'HEAD', 'OPTIONS'):
            return True
        return request.user.role == Role.DIRECTION
