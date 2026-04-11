from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import TokenRefreshView, TokenBlacklistView

urlpatterns = [
    path('admin/', admin.site.urls),

    # ── Auth ──────────────────────────────────────────────────────────────────
    path('api/auth/login/',   include('users.urls')),
    path('api/auth/refresh/', TokenRefreshView.as_view(),    name='token_refresh'),
    path('api/auth/logout/',  TokenBlacklistView.as_view(),  name='token_blacklist'),

    # ── API resources ─────────────────────────────────────────────────────────
    path('api/users/',          include('users.urls_users')),
    path('api/fournisseurs/',   include('fournisseurs.urls')),
    path('api/echantillons/',   include('echantillons.urls')),
    path('api/evaluations/',    include('evaluations.urls')),
    path('api/analyses/',       include('analyses.urls')),
    path('api/sessions/',       include('sessions_degustation.urls')),
    path('api/planifications/', include('planifications.urls')),
    path('api/messages/',       include('messages_chat.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
