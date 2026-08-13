class ApiEndpoints {
  const ApiEndpoints._();

  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const profile = '/profile';
  static const bodyOverview = '/profile/body-overview';
  static const generateWorkoutPlan = '/workout-plans/generate';
  static const currentWorkoutPlan = '/workout-plans/current';

  static String workoutSession(int id) => '/workout-sessions/$id';

  static String completeWorkoutSession(int id) => '/workout-sessions/$id/complete';

  static const progressSummary = '/progress/summary';

  static String weeklyProgress(int weeks) => '/progress/weekly?weeks=$weeks';
}
