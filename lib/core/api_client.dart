// dart:convert gives us jsonEncode (Dart object → JSON string) and jsonDecode (JSON string → Dart object).
// We need this because the server speaks JSON, not Dart.
import 'dart:convert';

// The http package lets us send messages over the internet (GET, POST, PUT, DELETE…).
// We alias it as "http" so we write http.get(...) instead of just get(...).
import 'package:http/http.dart' as http;

// flutter_secure_storage saves data in an encrypted safe on the device.
// We use it to store the login tokens — much safer than a regular file.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// config.dart holds kApiBaseUrl — the base address of our Django server (e.g. "http://192.168.1.10:8000").
// We keep it in one place so changing the server address is a one-line fix.
import '../config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ApiClient
//
// Think of this class as a POST OFFICE for the app.
// Every time the app needs to talk to the Django backend it goes through here.
// No page or widget is allowed to send HTTP requests on its own.
//
// Why centralise it?
//   • Every request automatically carries the user's login badge (token).
//   • If the badge expires, it is automatically renewed — no page has to care.
//   • Errors are handled in one place — no copy-pasted error handling everywhere.
//   • If the server address ever changes, we update one constant, not 50 files.
// ─────────────────────────────────────────────────────────────────────────────
class ApiClient {
  // The keys used to store the two tokens inside the secure storage.
  // Think of these as the label on the safe's drawer ("access_token" slot, "refresh_token" slot).
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // The base URL of the Django server, e.g. "http://192.168.1.10:8000".
  // Every request path is appended to this, e.g. baseUrl + "/api/samples/".
  final String baseUrl;

  // The encrypted safe where we store the tokens on the device.
  final FlutterSecureStorage _storage;

  // Constructor — if no baseUrl or storage is provided, use the defaults from config.dart.
  // This makes the class easy to test by injecting a fake storage or a test server URL.
  ApiClient({String? baseUrl, FlutterSecureStorage? storage})
    : baseUrl = baseUrl ?? kApiBaseUrl,
      _storage = storage ?? const FlutterSecureStorage();

  // ── Token management ──────────────────────────────────────────────────────
  //
  // After a successful login the server hands us two tokens:
  //
  //   access token  — a short-lived ID badge (~15 min). Attached to every request
  //                   so the server knows who is making the call.
  //
  //   refresh token — a long-lived key (days/weeks). Used ONLY to get a new
  //                   access token when the current one expires. Never sent to
  //                   regular API endpoints.
  //
  // Both tokens are saved in the encrypted safe (FlutterSecureStorage).
  // ─────────────────────────────────────────────────────────────────────────

  // Called right after login — saves both tokens to the encrypted safe.
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _tokenKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  // Called on logout — removes both tokens so the user is fully signed out.
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }

  // Reads the current access token from the safe (returns null if not logged in).
  Future<String?> get accessToken => _storage.read(key: _tokenKey);

  // Reads the current refresh token from the safe (returns null if not logged in).
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  // ── Internal helpers ──────────────────────────────────────────────────────

  // Builds the metadata that goes on top of every HTTP request (like the header of a letter).
  //
  //   'Content-Type: application/json'  → tells the server "my data is in JSON format".
  //   'Authorization: Bearer <token>'   → attaches the user's ID badge so the server
  //                                       knows who is making the call and allows it.
  //
  // If no token exists (user not logged in), the Authorization line is simply omitted.
  Future<Map<String, String>> _headers() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Combines the base server address with the specific endpoint path.
  // Example: baseUrl = "http://192.168.1.10:8000", path = "/api/samples/"
  //          → full URL = "http://192.168.1.10:8000/api/samples/"
  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Uri _uriFromPathOrUrl(String pathOrUrl) {
    final uri = Uri.parse(pathOrUrl);
    return uri.hasScheme ? uri : _uri(pathOrUrl);
  }

  // ── Auto token refresh ────────────────────────────────────────────────────
  //
  // The access token expires after ~15 minutes for security reasons.
  // When it expires, the server returns status code 401 ("I don't recognise you").
  //
  // Instead of forcing the user to log in again, we use the refresh token
  // to silently get a brand-new access token from the server, save it,
  // and retry the original request. The user never notices anything happened.
  // ─────────────────────────────────────────────────────────────────────────

  // TODO: add token refresh logic
  // Asks the server for a new access token using the refresh token.
  // Returns true if it worked, false if the refresh token is also expired
  // (in that case the user must log in again).
  Future<bool> _refreshAccessToken() async {
    final refresh = await refreshToken;
    if (refresh == null) {
      return false; // not logged in at all — nothing to refresh
    }

    // Send the refresh token to the server's dedicated refresh endpoint.
    final response = await http.post(
      _uri('/api/auth/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      // Server accepted it — extract the new access token and save it.
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.write(key: _tokenKey, value: data['access'] as String);
      return true;
    }
    return false; // refresh token also expired → user must log in again
  }

  // Sends a request and handles the 401 (expired token) case automatically.
  //
  // Flow:
  //   1. Send the request.
  //   2. If the server says 401 (badge expired) → call _refreshAccessToken().
  //   3. If refresh succeeded → retry the original request with the new token.
  //   4. Return whatever response we end up with.
  //
  // The caller (get / post / put / …) never has to think about token expiry.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    var response = await request();
    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) response = await request(); // retry with fresh token
    }
    return response;
  }

  // ── Error handling ────────────────────────────────────────────────────────
  //
  // Every HTTP response comes with a status code number:
  //   200–299 → success (everything is fine)
  //   400–499 → client error (we sent something wrong — bad data, not found, not allowed…)
  //   500–599 → server error (the Django server crashed or has a bug)
  //
  // If the status code is 400 or above, we throw an ApiException so the page
  // that triggered the call can catch it and show a proper error message to the user.
  // Without this, a failed request would silently return garbage and the UI would break.
  // ─────────────────────────────────────────────────────────────────────────
  void _assertSuccess(http.Response response) {
    if (response.statusCode >= 400) {
      // Try to extract the human-readable error message from the response body.
      // Django REST Framework usually sends: { "detail": "Not found." }
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final detail = body is Map
          ? (body['detail'] ?? body.toString())
          : body.toString();
      final code = body is Map ? body['code']?.toString() : null;
      throw ApiException(response.statusCode, detail.toString(), code: code);
    }
  }

  // ── Public API methods ────────────────────────────────────────────────────
  //
  // These are the only methods that service classes should call.
  // Each one:
  //   1. Builds the headers (including the auth token).
  //   2. Sends the request through _send() (which handles token refresh).
  //   3. Checks for errors with _assertSuccess().
  //   4. Decodes the JSON response and returns plain Dart objects.
  // ─────────────────────────────────────────────────────────────────────────

  // GET — fetch a single object from the server.
  // Example: apiClient.get('/api/samples/abc-123/') → returns one sample as a Map.
  Future<Map<String, dynamic>> get(String path) async {
    final headers = await _headers();
    final response = await _send(() => http.get(_uri(path), headers: headers));
    _assertSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // GET — fetch a list of objects from the server.
  //
  // Django REST Framework returns lists in a paginated envelope:
  //   { "count": 10000, "results": [ item1, item2, … ] }
  //
  // This method unwraps that envelope and returns just the items list,
  // so callers never have to deal with the wrapper themselves.
  Future<List<dynamic>> getList(String path) async {
    final headers = await _headers();
    String? nextUrl = path;
    final allItems = <dynamic>[];

    while (nextUrl != null) {
      final currentUrl = nextUrl;
      final response = await _send(
        () => http.get(_uriFromPathOrUrl(currentUrl), headers: headers),
      );
      _assertSuccess(response);
      final decoded = jsonDecode(response.body);

      // Paginated response - collect this page, then follow the next URL.
      if (decoded is Map && decoded.containsKey('results')) {
        allItems.addAll(decoded['results'] as List<dynamic>);
        final next = decoded['next'];
        nextUrl = next is String && next.isNotEmpty ? next : null;
        continue;
      }

      // Non-paginated — the server returned a plain list directly.
      return decoded as List<dynamic>;
    }

    return allItems;
  }

  // POST — send new data to the server to create a new record.
  // Example: apiClient.post('/api/samples/', sampleData) → returns the saved sample (with its new ID).
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final response = await _send(
      // jsonEncode converts the Dart Map into a JSON string that the server understands.
      () => http.post(_uri(path), headers: headers, body: jsonEncode(body)),
    );
    _assertSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // POST (multipart) — upload a file plus optional text fields.
  //
  // Used by sample creation when a bottle photo is attached.
  // Handles the same automatic token-refresh-and-retry as the other methods.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    String fileField = 'image',
    Map<String, String>? fields,
  }) async {
    Future<http.Response> build() async {
      final token = await accessToken;
      final request = http.MultipartRequest('POST', _uri(path));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (fields != null) request.fields.addAll(fields);
      request.files.add(
        http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
      );
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    }

    var response = await build();
    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) response = await build();
    }
    _assertSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // PUT — replace an entire existing record on the server.
  // You must send all fields, even the ones that did not change.
  // Example: apiClient.put('/api/samples/abc-123/', fullSampleData)
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final response = await _send(
      () => http.put(_uri(path), headers: headers, body: jsonEncode(body)),
    );
    _assertSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // PATCH — update only the fields you provide, leaving everything else unchanged.
  // More efficient than PUT when you only need to change one or two fields.
  // Example: apiClient.patch('/api/samples/abc-123/', {'statut': 'en_negociation'})
  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final response = await _send(
      () => http.patch(_uri(path), headers: headers, body: jsonEncode(body)),
    );
    _assertSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // DELETE — permanently remove a record from the server.
  // Example: apiClient.delete('/api/samples/abc-123/')
  Future<void> delete(String path) async {
    final headers = await _headers();
    final response = await _send(
      () => http.delete(_uri(path), headers: headers),
    );
    _assertSuccess(response);
  }

  // LOGIN — special method that does NOT use _send() because there is no token yet.
  //
  // Steps:
  //   1. Send email + password to the server.
  //   2. Server checks credentials and returns two tokens (access + refresh).
  //   3. We save both tokens to the encrypted safe.
  //   4. Return the full server response (which also contains the user's profile data).
  //
  // After this call succeeds, all subsequent requests will automatically carry the token.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      _uri('/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _assertSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    // Save the tokens so future requests are automatically authenticated.
    await saveTokens(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
    );
    return data;
  }

  // LOGOUT — asks Django to blacklist the refresh token, then clears local storage.
  Future<void> logout() async {
    final refresh = await refreshToken;
    try {
      if (refresh != null) {
        final headers = await _headers();
        await http.post(
          _uri('/api/auth/logout/'),
          headers: headers,
          body: jsonEncode({'refresh': refresh}),
        );
      }
    } finally {
      await clearTokens();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ApiException
//
// A custom error type thrown whenever the server returns a 4xx or 5xx status.
// Pages catch this to display a user-friendly error message instead of crashing.
//
// Example usage in a service:
//   try {
//     final data = await apiClient.get('/api/samples/');
//   } on ApiException catch (e) {
//     print('Error ${e.statusCode}: ${e.message}');
//   }
// ─────────────────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode; // the HTTP status code (e.g. 404, 500)
  final String message; // human-readable error message from the server
  final String? code; // optional machine-readable error code from Django
  ApiException(this.statusCode, this.message, {this.code});

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Singleton instance
//
// One single ApiClient is created here when the app starts.
// Every service class imports and uses THIS object — they never create their own.
//
// Why one shared instance?
//   The tokens are stored inside the ApiClient object.
//   If each service created its own ApiClient, they would not share the same
//   token state — one service might be "logged in" while another is not.
//   One shared instance = one source of truth for authentication.
// ─────────────────────────────────────────────────────────────────────────────
final apiClient = ApiClient();
