import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/workout_plan.dart';

class WorkoutService {
  final ApiClient _apiClient;

  WorkoutService(this._apiClient);

  Future<WorkoutPlan> generatePlan(DateTime startDate) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.generateWorkoutPlan,
      data: {
        'startDate': startDate.toIso8601String().split('T').first,
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Workout plan response was empty');
    }
    return WorkoutPlan.fromJson(data);
  }

  Future<WorkoutPlan?> getCurrentPlan() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.currentWorkoutPlan,
      );
      final data = response.data;
      return data == null ? null : WorkoutPlan.fromJson(data);
    } catch (error) {
      if (error.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }
}
