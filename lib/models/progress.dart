class ProgressSummary {
  final int fitnessScore;
  final int previousFitnessScore;
  final int workoutScore;
  final int consistencyScore;
  final int activityScore;
  final int recoveryScore;
  final int completedWorkouts;
  final int plannedWorkouts;
  final int totalWorkoutMinutes;
  final int currentStreak;

  const ProgressSummary({
    required this.fitnessScore,
    required this.previousFitnessScore,
    required this.workoutScore,
    required this.consistencyScore,
    required this.activityScore,
    required this.recoveryScore,
    required this.completedWorkouts,
    required this.plannedWorkouts,
    required this.totalWorkoutMinutes,
    required this.currentStreak,
  });

  int get scoreDelta => fitnessScore - previousFitnessScore;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      fitnessScore: json['fitnessScore'] as int,
      previousFitnessScore: json['previousFitnessScore'] as int,
      workoutScore: json['workoutScore'] as int,
      consistencyScore: json['consistencyScore'] as int,
      activityScore: json['activityScore'] as int,
      recoveryScore: json['recoveryScore'] as int,
      completedWorkouts: json['completedWorkouts'] as int,
      plannedWorkouts: json['plannedWorkouts'] as int,
      totalWorkoutMinutes: json['totalWorkoutMinutes'] as int,
      currentStreak: json['currentStreak'] as int,
    );
  }
}

class WeeklyProgress {
  final DateTime weekStart;
  final int fitnessScore;
  final int workoutScore;
  final int consistencyScore;
  final int activityScore;
  final int recoveryScore;

  const WeeklyProgress({
    required this.weekStart,
    required this.fitnessScore,
    required this.workoutScore,
    required this.consistencyScore,
    required this.activityScore,
    required this.recoveryScore,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      weekStart: DateTime.parse(json['weekStart'] as String),
      fitnessScore: json['fitnessScore'] as int,
      workoutScore: json['workoutScore'] as int,
      consistencyScore: json['consistencyScore'] as int,
      activityScore: json['activityScore'] as int,
      recoveryScore: json['recoveryScore'] as int,
    );
  }
}
