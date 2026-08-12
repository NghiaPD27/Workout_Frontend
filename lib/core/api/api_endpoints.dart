class ApiEndpoints {
  const ApiEndpoints._();

  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const profile = '/profile';
  static const bodyOverview = '/profile/body-overview';
  static const generateWorkoutPlan = '/workout-plans/generate';
  static const currentWorkoutPlan = '/workout-plans/current';
}
