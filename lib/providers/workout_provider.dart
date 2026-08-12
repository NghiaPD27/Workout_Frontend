import 'package:flutter/foundation.dart';

import '../models/workout_plan.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  WorkoutPlan? currentPlan;
  bool isLoading = false;
  String? errorMessage;

  WorkoutProvider(this._workoutService);

  Future<void> loadCurrentPlan() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentPlan = await _workoutService.getCurrentPlan();
    } catch (_) {
      errorMessage = 'Could not load your workout plan.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generatePlan(DateTime startDate) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentPlan = await _workoutService.generatePlan(startDate);
      return true;
    } catch (_) {
      errorMessage = 'Could not generate your workout plan. Please check your profile and try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
