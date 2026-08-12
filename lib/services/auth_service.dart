import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/secure_token_storage.dart';
import '../models/auth_session.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  AuthService(this._apiClient, this._tokenStorage);

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return _saveSession(response.data);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return _saveSession(response.data);
  }

  Future<bool> hasStoredSession() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }

  Future<void> logout() => _tokenStorage.clear();

  Future<AuthSession> _saveSession(Map<String, dynamic>? data) async {
    if (data == null) {
      throw StateError('Auth response was empty');
    }

    final session = AuthSession.fromJson(data);
    await _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }
}
