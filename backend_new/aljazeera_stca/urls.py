from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

urlpatterns = [
    # ── Django admin ──────────────────────────────────────────────────────────
    path('admin/', admin.site.urls),

    # ── Auth ──────────────────────────────────────────────────────────────────
    path('api/auth/login/', TokenObtainPairView.as_view(), name='login'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token-refresh'),

    # ── Domain APIs ───────────────────────────────────────────────────────────
    path('api/users/', include('users.urls')),
    path('api/fournisseurs/', include('fournisseurs.urls')),
    path('api/echantillons/', include('echantillons.urls')),
    path('api/evaluations/', include('evaluations.urls')),
    path('api/analyses/', include('analyses.urls')),
    path('api/sessions_degustation/', include('sessions_degustation.urls')),
    path('api/planifications/', include('planifications.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/messages_chat/', include('messages_chat.urls')),

    # ── Interactive API docs (Swagger UI) ─────────────────────────────────────
    # Visit http://localhost:8000/api/docs/  to see and test every endpoint
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]
