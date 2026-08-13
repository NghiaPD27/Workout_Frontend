import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService;

  ProgressSummary? summary;
  List<WeeklyProgress> weeklyProgress = const [];
  bool isLoading = false;
  String? errorMessage;

  ProgressProvider(this._progressService);

  Future<void> loadProgress() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      summary = await _progressService.getSummary();
      weeklyProgress = await _progressService.getWeeklyProgress(weeks: 8);
    } catch (_) {
      errorMessage = 'Could not load progress.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
