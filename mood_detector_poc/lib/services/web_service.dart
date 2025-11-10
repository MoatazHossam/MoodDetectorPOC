import 'dart:convert';

import 'package:http/http.dart' as http;

/// A lightweight HTTP client wrapper that centralizes the configuration for
/// calling remote web services.
class WebService {
  WebService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  /// Base URL used for every request, e.g. `https://api.example.com/`.
  final String baseUrl;

  final http.Client _client;

  /// Performs an HTTP GET request.
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _client.get(uri, headers: headers);
  }

  /// Performs an HTTP POST request with optional JSON encoding.
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool encodeJson = true,
  }) {
    final uri = _buildUri(path, queryParameters);
    final resolvedHeaders = _mergeHeaders(headers);
    final resolvedBody = _prepareBody(body, resolvedHeaders, encodeJson);
    return _client.post(uri, headers: resolvedHeaders, body: resolvedBody);
  }

  /// Performs an HTTP PUT request with optional JSON encoding.
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool encodeJson = true,
  }) {
    final uri = _buildUri(path, queryParameters);
    final resolvedHeaders = _mergeHeaders(headers);
    final resolvedBody = _prepareBody(body, resolvedHeaders, encodeJson);
    return _client.put(uri, headers: resolvedHeaders, body: resolvedBody);
  }

  /// Performs an HTTP PATCH request with optional JSON encoding.
  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool encodeJson = true,
  }) {
    final uri = _buildUri(path, queryParameters);
    final resolvedHeaders = _mergeHeaders(headers);
    final resolvedBody = _prepareBody(body, resolvedHeaders, encodeJson);
    return _client.patch(uri, headers: resolvedHeaders, body: resolvedBody);
  }

  /// Performs an HTTP DELETE request with optional JSON encoding.
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool encodeJson = true,
  }) {
    final uri = _buildUri(path, queryParameters);
    final resolvedHeaders = _mergeHeaders(headers);
    final resolvedBody = _prepareBody(body, resolvedHeaders, encodeJson);
    return _client.delete(uri, headers: resolvedHeaders, body: resolvedBody);
  }

  /// Releases the underlying HTTP client resources.
  void dispose() {
    _client.close();
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final baseUri = Uri.parse(baseUrl);
    final resolved = baseUri.resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }

    return resolved.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };
  }

  Object? _prepareBody(
    Object? body,
    Map<String, String> headers,
    bool encodeJson,
  ) {
    if (body == null) {
      return null;
    }

    if (!encodeJson) {
      return body;
    }

    if (body is String || body is List<int>) {
      return body;
    }

    if (body is Map || body is Iterable) {
      headers.putIfAbsent('Content-Type', () => 'application/json');
      return jsonEncode(body);
    }

    return body;
  }
}
