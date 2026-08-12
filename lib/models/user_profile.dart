enum ActivityLevel {
  low('LOW', 'Low'),
  medium('MEDIUM', 'Medium'),
  high('HIGH', 'High');

  const ActivityLevel(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum ExperienceLevel {
  beginner('BEGINNER', 'Beginner'),
  intermediate('INTERMEDIATE', 'Intermediate'),
  advanced('ADVANCED', 'Advanced');

  const ExperienceLevel(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum FitnessGoal {
  improveFitness('IMPROVE_FITNESS', 'Improve fitness'),
  loseWeight('LOSE_WEIGHT', 'Lose weight'),
  buildMuscle('BUILD_MUSCLE', 'Build muscle'),
  stayActive('STAY_ACTIVE', 'Stay active');

  const FitnessGoal(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class UserProfile {
  final int id;
  final DateTime? birthDate;
  final int heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final ExperienceLevel experienceLevel;
  final FitnessGoal goal;
  final int daysPerWeek;
  final int sessionMinutes;

  const UserProfile({
    required this.id,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.experienceLevel,
    required this.goal,
    required this.daysPerWeek,
    required this.sessionMinutes,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      heightCm: json['heightCm'] as int,
      weightKg: (json['weightKg'] as num).toDouble(),
      activityLevel: _activityFromApi(json['activityLevel'] as String),
      experienceLevel: _experienceFromApi(json['experienceLevel'] as String),
      goal: _goalFromApi(json['goal'] as String),
      daysPerWeek: json['daysPerWeek'] as int,
      sessionMinutes: json['sessionMinutes'] as int,
    );
  }

  static ActivityLevel _activityFromApi(String value) {
    return ActivityLevel.values.firstWhere((item) => item.apiValue == value);
  }

  static ExperienceLevel _experienceFromApi(String value) {
    return ExperienceLevel.values.firstWhere((item) => item.apiValue == value);
  }

  static FitnessGoal _goalFromApi(String value) {
    return FitnessGoal.values.firstWhere((item) => item.apiValue == value);
  }
}

class ProfilePayload {
  final DateTime? birthDate;
  final int heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final ExperienceLevel experienceLevel;
  final FitnessGoal goal;
  final int daysPerWeek;
  final int sessionMinutes;

  const ProfilePayload({
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.experienceLevel,
    required this.goal,
    required this.daysPerWeek,
    required this.sessionMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'birthDate': birthDate?.toIso8601String().split('T').first,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel.apiValue,
      'experienceLevel': experienceLevel.apiValue,
      'goal': goal.apiValue,
      'daysPerWeek': daysPerWeek,
      'sessionMinutes': sessionMinutes,
    };
  }
}
