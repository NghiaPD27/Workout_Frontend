import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

enum AuthStatus {
  checking,
  unauthenticated,
  needsProfile,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;

  AuthStatus status = AuthStatus.checking;
  User? user;
  String? errorMessage;
  bool isLoading = false;

  AuthProvider(this._authService, this._profileService);

  Future<void> bootstrap() async {
    status = AuthStatus.checking;
    notifyListeners();

    final hasSession = await _authService.hasStoredSession();
    if (!hasSession) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    await _loadProfileState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      final session = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      user = session.user;
      status = AuthStatus.needsProfile;
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      final session = await _authService.login(email: email, password: password);
      user = session.user;
      await _loadProfileState(notify: false);
    });
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> markProfileComplete() async {
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> _loadProfileState({bool notify = true}) async {
    try {
      final profile = await _profileService.getProfile();
      status = profile == null ? AuthStatus.needsProfile : AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
      await _authService.logout();
    }

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = _friendlyError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('401')) {
      return 'Email or password is not correct.';
    }
    if (text.contains('400')) {
      return 'Please check your information and try again.';
    }
    return 'Could not connect to FitPlan. Please try again.';
  }
}
