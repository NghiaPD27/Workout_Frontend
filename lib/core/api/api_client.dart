import 'package:dio/dio.dart';

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
      handler.next(error);
      return;
    }

    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
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
      handler.resolve(response);
    } catch (_) {
      _refreshFuture = null;
      await tokenStorage.clear();
      handler.next(error);
    }
  }

  Future<void> _refreshTokens(String refreshToken) async {
    final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
    final response = await refreshDio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Refresh response was empty');
    }

    await tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}
