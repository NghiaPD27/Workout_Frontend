import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/progress.dart';

class ProgressService {
  final ApiClient _apiClient;

  ProgressService(this._apiClient);

  Future<ProgressSummary> getSummary() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.progressSummary,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Progress summary response was empty');
    }
    return ProgressSummary.fromJson(data);
  }

  Future<List<WeeklyProgress>> getWeeklyProgress({int weeks = 8}) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      ApiEndpoints.weeklyProgress(weeks),
    );
    final data = response.data ?? [];
    return data
        .map((item) => WeeklyProgress.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
