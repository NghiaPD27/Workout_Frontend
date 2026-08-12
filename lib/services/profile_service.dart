import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/body_overview.dart';
import '../models/user_profile.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<UserProfile?> getProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.profile,
      );
      final data = response.data;
      return data == null ? null : UserProfile.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<UserProfile> saveProfile(ProfilePayload payload) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: payload.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Profile response was empty');
    }
    return UserProfile.fromJson(data);
  }

  Future<BodyOverview> getBodyOverview() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.bodyOverview,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Body overview response was empty');
    }
    return BodyOverview.fromJson(data);
  }
}
