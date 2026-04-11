import uuid
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class Role(models.TextChoices):
    DIRECTION    = 'direction',    'Direction'
    COLLECTEUR   = 'collecteur',   'Collecteur'
    DEGUSTATEUR  = 'degustateur',  'Dégustateur'
    LABORATOIRE  = 'laboratoire',  'Technicien Labo'


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra):
        extra.setdefault('is_staff', True)
        extra.setdefault('is_superuser', True)
        extra.setdefault('role', Role.DIRECTION)
        return self.create_user(email, password, **extra)


class User(AbstractBaseUser, PermissionsMixin):
    # ── Primary key ──────────────────────────────────────────────────────────
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # ── Identity ─────────────────────────────────────────────────────────────
    email = models.EmailField(unique=True)
    role  = models.CharField(max_length=20, choices=Role.choices, default=Role.COLLECTEUR)

    # ── Personal info ─────────────────────────────────────────────────────────
    nom        = models.CharField(max_length=100)
    prenom     = models.CharField(max_length=100)
    telephone  = models.CharField(max_length=30, blank=True, null=True)
    photo_url  = models.ImageField(upload_to='users/photos/', blank=True, null=True)

    # ── Account state ─────────────────────────────────────────────────────────
    is_active  = models.BooleanField(default=True)
    is_staff   = models.BooleanField(default=False)

    # ── Timestamps ────────────────────────────────────────────────────────────
    date_creation = models.DateTimeField(auto_now_add=True)
    last_login    = models.DateTimeField(blank=True, null=True)  # updated by JWT

    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['nom', 'prenom', 'role']

    objects = UserManager()

    class Meta:
        db_table = 'users'
        ordering = ['nom', 'prenom']

    def __str__(self):
        return f'{self.prenom} {self.nom} ({self.role})'

    @property
    def nom_complet(self):
        return f'{self.prenom} {self.nom}'
