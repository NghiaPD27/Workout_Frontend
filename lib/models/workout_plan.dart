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
