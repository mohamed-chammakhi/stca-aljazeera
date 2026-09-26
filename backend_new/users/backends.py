from django.contrib.auth.backends import BaseBackend

from .models import User


class EmailActifBackend(BaseBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        email = kwargs.get(User.USERNAME_FIELD) or username
        if not email or password is None:
            return None
        try:
            user = User.objects.get(
                email__iexact=email,
                date_suppression__isnull=True,
            )
        except User.DoesNotExist:
            User().set_password(password)
            return None
        except User.MultipleObjectsReturned:
            return None
        if user.check_password(password) and self.user_can_authenticate(user):
            return user
        return None

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id, date_suppression__isnull=True)
        except User.DoesNotExist:
            return None

    def user_can_authenticate(self, user):
        return user.is_active
