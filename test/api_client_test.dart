import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project3/core/api_client.dart';

class _FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('retry after token refresh uses the new access token', () async {
    final storage = _FakeSecureStorage();
    final sentAuthorizations = <String?>[];

    final httpClient = MockClient((request) async {
      if (request.url.path == '/api/auth/refresh/') {
        return http.Response(jsonEncode({'access': 'new-token'}), 200);
      }

      sentAuthorizations.add(request.headers['Authorization']);
      if (request.headers['Authorization'] == 'Bearer old-token') {
        return http.Response(jsonEncode({'detail': 'expired'}), 401);
      }
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    final api = ApiClient(
      baseUrl: 'http://test.invalid',
      storage: storage,
      httpClient: httpClient,
    );
    await api.saveTokens(access: 'old-token', refresh: 'refresh-token');

    final response = await api.get('/api/protected/');

    expect(response, {'ok': true});
    expect(sentAuthorizations, ['Bearer old-token', 'Bearer new-token']);
  });

  test('parallel 401s share one refresh and keep the rotated refresh token',
      () async {
    final storage = _FakeSecureStorage();
    var refreshCalls = 0;

    final httpClient = MockClient((request) async {
      if (request.url.path == '/api/auth/refresh/') {
        refreshCalls++;
        return http.Response(
          jsonEncode({'access': 'new-token', 'refresh': 'new-refresh'}),
          200,
        );
      }
      if (request.headers['Authorization'] == 'Bearer old-token') {
        return http.Response(jsonEncode({'detail': 'expired'}), 401);
      }
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    final api = ApiClient(
      baseUrl: 'http://test.invalid',
      storage: storage,
      httpClient: httpClient,
    );
    await api.saveTokens(access: 'old-token', refresh: 'refresh-token');

    await Future.wait([api.get('/api/a/'), api.get('/api/b/')]);

    expect(refreshCalls, 1);
    expect(await api.refreshToken, 'new-refresh');
  });
}
