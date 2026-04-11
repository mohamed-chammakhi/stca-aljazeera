# Al Jazeera STCA — Django Backend

## Stack
- **Django 4.2** + **Django REST Framework**
- **PostgreSQL** (UUID primary keys, snake_case fields)
- **JWT auth** via `djangorestframework-simplejwt`
- **CORS** via `django-cors-headers`
- **Filtering** via `django-filter`

## Quick start

```bash
# 1. Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment
cp .env.example .env
# Edit .env — set SECRET_KEY, DB_NAME, DB_USER, DB_PASSWORD, etc.

# 4. Create the PostgreSQL database
psql -U postgres -c "CREATE DATABASE aljazeera_stca;"

# 5. Run migrations
python manage.py migrate

# 6. Create a superuser (Direction role)
python manage.py createsuperuser

# 7. Start the dev server
python manage.py runserver
```

The API is available at `http://localhost:8000/api/`.
The Django admin is at `http://localhost:8000/admin/`.

---

## API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| POST | `/api/auth/login/` | Login — returns `access`, `refresh`, `user` |
| POST | `/api/auth/refresh/` | Refresh access token |
| POST | `/api/auth/logout/` | Blacklist refresh token |
| GET/POST | `/api/users/` | List / create users (Direction only for POST) |
| GET | `/api/users/me/` | Current user profile |
| GET/PATCH/DELETE | `/api/users/<id>/` | User detail |
| GET/POST | `/api/fournisseurs/` | Suppliers |
| GET/POST | `/api/echantillons/` | Samples |
| PATCH | `/api/echantillons/<id>/approve/` | Direction approves sample |
| PATCH | `/api/echantillons/<id>/reject/` | Direction rejects sample |
| PATCH | `/api/echantillons/<id>/confirm_reception/` | Taster confirms physical arrival |
| PATCH | `/api/echantillons/<id>/confirm_purchase/` | Collector confirms purchase |
| GET/POST | `/api/evaluations/` | Organoleptic evaluations |
| GET/POST | `/api/analyses/` | Lab analyses (with nested criteres) |
| POST | `/api/analyses/<id>/submit/` | Submit lab analysis |
| GET/POST | `/api/sessions/` | Tasting sessions |
| GET/POST | `/api/planifications/arrivage/` | Arrival schedules |
| GET/POST | `/api/planifications/livraison/` | Delivery schedules |
| GET/POST | `/api/messages/` | Chat messages |
| PATCH | `/api/messages/<id>/mark_read/` | Mark message as read |

All endpoints (except login) require `Authorization: Bearer <access_token>`.

---

## App structure

```
backend/
├── aljazeera_stca/        # Django project config
├── users/                 # Custom user model + JWT auth
├── fournisseurs/          # Suppliers
├── echantillons/          # Samples (core entity)
├── evaluations/           # Organoleptic evaluations
├── analyses/              # Lab analyses + criteria
├── sessions_degustation/  # Tasting sessions
├── planifications/        # Arrivage + livraison schedules
└── messages_chat/         # Collector ↔ Direction chat
```

---

## Connecting to Flutter

In `lib/config.dart`, set:
```dart
const String apiBaseUrl = 'http://10.0.2.2:8000/api';  // Android emulator
// const String apiBaseUrl = 'http://localhost:8000/api';  // iOS simulator
```

The Android emulator routes `10.0.2.2` to the host machine's `localhost`.
