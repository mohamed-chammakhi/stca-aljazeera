from rest_framework.permissions import BasePermission


class IsRole(BasePermission):
    """
    Reusable role-based permission. Usage in any view:

        permission_classes = [IsAuthenticated, IsRole('direction')]
        permission_classes = [IsAuthenticated, IsRole('degustateur', 'chef_panel')]
    """

    def __init__(self, *roles):
        self.roles = roles

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role in self.roles
        )


# Ready-made permission classes for each role — import and use directly in views.

class IsDirection(BasePermission):
    """CEO / Direction only."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'direction'


class IsCollecteur(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'collecteur'


class IsDegustateur(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'degustateur'


class IsLaboratoire(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'laboratoire'


class IsChefPanel(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'chef_panel'


class IsDegustateurOrChefPanel(BasePermission):
    """Taster pages accessible to both degustateur and chef_panel."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ('degustateur', 'chef_panel')


class IsDirectionOrReadOnly(BasePermission):
    """CEO can write; all authenticated users can read."""
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        if request.method in ('GET', 'HEAD', 'OPTIONS'):
            return True
        return request.user.role == 'direction'
