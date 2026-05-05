# backend.md — Services, Models & Backend Integration

> Read when working on services, models, ApiClient, auth, or offline sync.

---

## Service Layer Pattern (mandatory)

All data access goes through a service. Pages call services; services return models; models built from JSON.

```dart
class EchantillonService {
  // TODO: inject ApiClient here when backend is ready

  Future<List<Echantillon>> fetchEchantillons() async {
    // TODO: replace with: return _api.get('/echantillons/');
    return _mockEchantillons();
  }

  Future<Echantillon> createEchantillon(Echantillon e) async {
    // TODO: replace with: return _api.post('/echantillons/', e.toJson());
    return e;
  }

  List<Echantillon> _mockEchantillons() => []; // TODO: remove when backend is ready
}
```

---

## Model Requirements

Both `fromJson()` and `toJson()` are mandatory on every model.

```dart
class Echantillon {
  final String id;                  // String UUID — never int
  final String numero;              // Auto-generated: "YYYY/NNNN" — read-only
  final String referenceBouteille;  // Physical bottle label typed by collector

  factory Echantillon.fromJson(Map<String, dynamic> json) => Echantillon(
    id:                  json['id']                   as String,
    numero:              json['numero']               as String,
    referenceBouteille:  json['reference_bouteille']  as String,
  );

  Map<String, dynamic> toJson() => {
    'reference_bouteille': referenceBouteille,
    // 'numero' is server-assigned — do not include in create/update payloads
  };

  // Paginated list helper:
  static List<Echantillon> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => Echantillon.fromJson(e)).toList();
}
```

- IDs: `String` (UUID), never `int`
- JSON keys: `snake_case` always

---

## ApiClient Skeleton (`lib/core/api_client.dart`)

Single instance created at app startup — do not instantiate inside services.

```dart
class ApiClient {
  final String baseUrl;
  String? _authToken;

  ApiClient({required this.baseUrl});

  void setToken(String token) => _authToken = token;
  void clearToken() => _authToken = null;

  Future<dynamic> get(String path) async {
    // TODO: implement with http or dio
    throw UnimplementedError('Backend not connected yet');
  }
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    throw UnimplementedError('Backend not connected yet');
  }
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    throw UnimplementedError('Backend not connected yet');
  }
  Future<void> delete(String path) async {
    throw UnimplementedError('Backend not connected yet');
  }
}
```

---

## Authentication (JWT)

- Backend: `djangorestframework-simplejwt`
- After login: store token in `flutter_secure_storage` (NOT `SharedPreferences`)
- Every request: `Authorization: Bearer <token>` header in `ApiClient`
- Add `// TODO: add token refresh logic` marker in `ApiClient`
- Login page already has `// TODO: replace with real API call` — keep it

---

## Django API Conventions

| | Detail |
|---|---|
| Base URL | `lib/config.dart` → `apiBaseUrl` |
| IDs | UUIDs (string) |
| Field names | `snake_case` |
| Lists | `{ "count": N, "results": [...] }` |
| Errors | `{ "detail": "..." }` or `{ "field": ["error"] }` |
| Dates | ISO 8601 (`"2024-11-03T14:22:00Z"`) |
| File uploads | `multipart/form-data` |

---

## What NOT to Do

- ❌ HTTP calls directly in `build()` or `initState()`
- ❌ `int` for IDs
- ❌ `camelCase` in JSON keys
- ❌ Auth tokens in `SharedPreferences`
- ❌ `baseUrl` hardcoded outside `lib/config.dart`
