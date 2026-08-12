import 'package:flutter/foundation.dart';

import '../models/body_overview.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;

  UserProfile? profile;
  BodyOverview? bodyOverview;
  bool isLoading = false;
  String? errorMessage;

  ProfileProvider(this._profileService);

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _profileService.getProfile();
      if (profile != null) {
        bodyOverview = await _profileService.getBodyOverview();
      }
    } catch (_) {
      errorMessage = 'Could not load your profile.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(ProfilePayload payload) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _profileService.saveProfile(payload);
      bodyOverview = await _profileService.getBodyOverview();
      return true;
    } catch (_) {
      errorMessage = 'Could not save your profile. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
