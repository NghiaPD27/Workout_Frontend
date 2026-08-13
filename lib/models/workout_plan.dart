enum WorkoutType {
  upper('UPPER', 'Upper Body'),
  lower('LOWER', 'Lower Body'),
  core('CORE', 'Core'),
  fullBody('FULL_BODY', 'Full Body'),
  cardio('CARDIO', 'Cardio'),
  mobility('MOBILITY', 'Mobility');

  const WorkoutType(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum WorkoutSessionStatus {
  planned('PLANNED', 'Planned'),
  completed('COMPLETED', 'Completed'),
  skipped('SKIPPED', 'Skipped');

  const WorkoutSessionStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum WorkoutPlanStatus {
  active('ACTIVE', 'Active'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled');

  const WorkoutPlanStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class WorkoutPlan {
  final int id;
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final WorkoutPlanStatus status;
  final List<WorkoutSessionSummary> sessions;

  const WorkoutPlan({
    required this.id,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.sessions,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final sessionsJson = json['sessions'] as List<dynamic>? ?? [];
    return WorkoutPlan(
      id: json['id'] as int,
      goal: json['goal'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _planStatusFromApi(json['status'] as String),
      sessions: sessionsJson
          .map((item) => WorkoutSessionSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static WorkoutPlanStatus _planStatusFromApi(String value) {
    return WorkoutPlanStatus.values.firstWhere((item) => item.apiValue == value);
  }
}

class WorkoutSessionSummary {
  final int id;
  final DateTime date;
  final String name;
  final WorkoutType workoutType;
  final int duration;
  final WorkoutSessionStatus status;

  const WorkoutSessionSummary({
    required this.id,
    required this.date,
    required this.name,
    required this.workoutType,
    required this.duration,
    required this.status,
  });

  factory WorkoutSessionSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionSummary(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      workoutType: _workoutTypeFromApi(json['workoutType'] as String),
      duration: json['duration'] as int,
      status: _sessionStatusFromApi(json['status'] as String),
    );
  }

  static WorkoutType _workoutTypeFromApi(String value) {
    return WorkoutType.values.firstWhere((item) => item.apiValue == value);
  }

  static WorkoutSessionStatus _sessionStatusFromApi(String value) {
    return WorkoutSessionStatus.values.firstWhere((item) => item.apiValue == value);
  }
}

class WorkoutSessionDetail {
  final int id;
  final String name;
  final WorkoutType workoutType;
  final DateTime date;
  final int estimatedMinutes;
  final WorkoutSessionStatus status;
  final List<WorkoutExercise> exercises;

  const WorkoutSessionDetail({
    required this.id,
    required this.name,
    required this.workoutType,
    required this.date,
    required this.estimatedMinutes,
    required this.status,
    required this.exercises,
  });

  factory WorkoutSessionDetail.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
    return WorkoutSessionDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      workoutType: WorkoutSessionSummary._workoutTypeFromApi(json['workoutType'] as String),
      date: DateTime.parse(json['date'] as String),
      estimatedMinutes: json['estimatedMinutes'] as int,
      status: WorkoutSessionSummary._sessionStatusFromApi(json['status'] as String),
      exercises: exercisesJson
          .map((item) => WorkoutExercise.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WorkoutExercise {
  final int id;
  final int exerciseId;
  final String name;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int orderIndex;

  const WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.durationSeconds,
    required this.orderIndex,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as int,
      exerciseId: json['exerciseId'] as int,
      name: json['name'] as String,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      orderIndex: json['orderIndex'] as int,
    );
  }

  int get targetSets => sets ?? 1;

  String get prescription {
    final setsText = sets == null ? '1' : sets.toString();
    if (reps != null) {
      return '$setsText x $reps reps';
    }
    if (durationSeconds != null) {
      return '$setsText x ${durationSeconds}s';
    }
    return '$setsText sets';
  }
}
