import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_token_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  final SecureTokenStorage tokenStorage;
  late final Dio dio;
  Future<void>? _refreshFuture;

  ApiClient(this.tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _addAuthorizationHeader,
        onResponse: _logResponse,
        onError: _handleUnauthorized,
      ),
    );
  }

  Future<void> _addAuthorizationHeader(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  Future<void> _handleUnauthorized(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;
    final request = error.requestOptions;
    final isAuthRefresh = request.path.endsWith(ApiEndpoints.refresh);
    final alreadyRetried = request.extra['retried'] == true;

    if (statusCode != 401 || isAuthRefresh || alreadyRetried) {
      _logError(error);
      handler.next(error);
      return;
    }

    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _logError(error);
      handler.next(error);
      return;
    }

    try {
      _refreshFuture ??= _refreshTokens(refreshToken);
      await _refreshFuture;
      _refreshFuture = null;

      final accessToken = await tokenStorage.readAccessToken();
      request.extra['retried'] = true;
      request.headers['Authorization'] = 'Bearer $accessToken';
      final response = await dio.fetch<dynamic>(request);
      _logApiResponse(response);
      handler.resolve(response);
    } catch (_) {
      _refreshFuture = null;
      await tokenStorage.clear();
      _logError(error);
      handler.next(error);
    }
  }

  Future<void> _refreshTokens(String refreshToken) async {
    final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
    final response = await refreshDio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    _logApiResponse(response);

    final data = response.data;
    if (data == null) {
      throw StateError('Refresh response was empty');
    }

    await tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  void _logResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logApiResponse(response);
    handler.next(response);
  }

  void _logError(DioException error) {
    if (!kDebugMode) {
      return;
    }

    final response = error.response;
    final request = error.requestOptions;
    final status = response?.statusCode ?? 'network-error';
    final body = response?.data;
    final redactedBody = _redactSensitiveData(body);

    debugPrint('[API] ${request.method} ${request.uri} -> $status');
    if (body is Map<String, dynamic>) {
      debugPrint('[API] error: ${body['message'] ?? error.message}');
      final validationErrors = body['validationErrors'];
      if (validationErrors is Map && validationErrors.isNotEmpty) {
        debugPrint('[API] validationErrors: ${_prettyJson(validationErrors)}');
      }
    } else if (error.message != null) {
      debugPrint('[API] error: ${error.message}');
    }
    debugPrint('[API] response: ${_prettyJson(redactedBody)}');
  }

  void _logApiResponse(Response<dynamic> response) {
    if (!kDebugMode) {
      return;
    }

    final request = response.requestOptions;
    debugPrint(
      '[API] ${request.method} ${request.uri} -> ${response.statusCode}',
    );
    debugPrint(
      '[API] response: ${_prettyJson(_redactSensitiveData(response.data))}',
    );
  }

  Object? _redactSensitiveData(Object? value) {
    const sensitiveKeys = {
      'authorization',
      'password',
      'accesstoken',
      'refreshtoken',
    };

    if (value is Map) {
      return value.map((key, item) {
        final normalizedKey = key
            .toString()
            .replaceAll(RegExp(r'[_-]'), '')
            .toLowerCase();
        if (sensitiveKeys.contains(normalizedKey)) {
          return MapEntry(key, '***REDACTED***');
        }
        return MapEntry(key, _redactSensitiveData(item));
      });
    }

    if (value is List) {
      return value.map(_redactSensitiveData).toList();
    }

    return value;
  }

  String _prettyJson(Object? value) {
    if (value == null) {
      return 'null';
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
