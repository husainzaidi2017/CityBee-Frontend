import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../errors/app_exception.dart';

/// Pagination block attached to list responses by the API.
class ApiPagination {
  const ApiPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
  });

  factory ApiPagination.fromJson(Map<String, dynamic> json) => ApiPagination(
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 20,
        total: (json['total'] as num?)?.toInt() ?? 0,
        hasNext: json['hasNext'] as bool? ?? false,
      );

  final int page;
  final int limit;
  final int total;
  final bool hasNext;
}

/// Result envelope used by every API response.
class ApiEnvelope<T> {
  const ApiEnvelope({required this.data, this.pagination});

  final T data;
  final ApiPagination? pagination;
}

/// Supplier of the current Supabase access token, injected to avoid a
/// circular dependency with the auth layer.
typedef TokenProvider = FutureOr<String?> Function();

/// Thin HTTP client for the CityBee NestJS API.
///
/// - Unwraps the `{success, data, message}` envelope
/// - Attaches the auth bearer token when one is available
/// - Maps transport/status errors onto the app's [AppException] hierarchy so
///   screens never see raw HTTP exceptions
class ApiClient {
  ApiClient({http.Client? client, TokenProvider? tokenProvider})
      : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider;

  final http.Client _client;
  final TokenProvider? _tokenProvider;

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    return _send(() async => _client.get(uri, headers: await _headers()));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    return _send(() async => _client.post(
          uri,
          headers: await _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    return _send(() async => _client.patch(
          uri,
          headers: await _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    return _send(() async => _client.delete(
          uri,
          headers: await _headers(json: body != null),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  /// GET returning a list plus its pagination block.
  Future<ApiEnvelope<List<dynamic>>?> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    // The raw envelope is parsed in _sendRaw so pagination survives.
    final decoded = await _sendRaw('GET', path, query: query);
    final data = decoded['data'];
    final paginationJson = decoded['pagination'];
    if (data is! List) return null;
    return ApiEnvelope(
      data: data,
      pagination: paginationJson is Map<String, dynamic>
          ? ApiPagination.fromJson(paginationJson)
          : null,
    );
  }

  // ── internals ───────────────────────────────────────────────────────────

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return base.replace(
      path: '${base.path}$path',
      queryParameters: (query == null || query.isEmpty)
          ? (base.queryParameters.isEmpty ? null : base.queryParameters)
          : query,
    );
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final headers = <String, String>{
      if (json) 'Content-Type': 'application/json',
    };
    final token = await _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _send(Future<http.Response> Function() action) async {
    final decoded = await _guard(action);
    return decoded['data'];
  }

  Future<Map<String, dynamic>> _sendRaw(
    String method,
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, query);
    return _guard(
      () async {
        switch (method) {
          case 'POST':
            return _client.post(uri, headers: await _headers(json: true));
          default:
            return _client.get(uri, headers: await _headers());
        }
      },
      label: '$method $uri',
    );
  }

  Future<Map<String, dynamic>> _guard(
    Future<http.Response> Function() action, {
    String label = 'request',
  }) async {
    http.Response response;
    try {
      response = await action().timeout(const Duration(seconds: 20));
    } catch (e) {
      developer.log('API $label TRANSPORT ERROR: $e', name: 'CityBeeAPI');
      throw const NetworkException();
    }

    if (response.statusCode >= 500) {
      developer.log('API $label -> 500: ${response.body}', name: 'CityBeeAPI');
      throw const ServerException();
    }

    Map<String, dynamic> decoded;
    try {
      decoded =
          response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      developer.log('API $label BAD JSON (${response.statusCode}): ${response.body}', name: 'CityBeeAPI');
      throw const ServerException();
    }

    if (response.statusCode >= 400) {
      developer.log('API $label -> ${response.statusCode}: ${response.body}', name: 'CityBeeAPI');
      throw AppExceptionWithMessage(
        decoded['message'] as String? ?? 'Request failed. Please try again.',
      );
    }

    if (decoded['success'] == false) {
      throw AppExceptionWithMessage(decoded['message'] as String? ?? 'Request failed.');
    }
    return decoded;
  }
}
