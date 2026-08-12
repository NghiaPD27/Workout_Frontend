import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:workout_frontend/core/api/api_client.dart';
import 'package:workout_frontend/core/storage/secure_token_storage.dart';
import 'package:workout_frontend/providers/auth_provider.dart';
import 'package:workout_frontend/providers/profile_provider.dart';
import 'package:workout_frontend/providers/workout_provider.dart';
import 'package:workout_frontend/screens/auth/login_screen.dart';
import 'package:workout_frontend/screens/onboarding/profile_onboarding_screen.dart';
import 'package:workout_frontend/screens/schedule/generate_plan_screen.dart';
import 'package:workout_frontend/services/auth_service.dart';
import 'package:workout_frontend/services/profile_service.dart';
import 'package:workout_frontend/services/workout_service.dart';

void main() {
  testWidgets('login form validates required fields', (tester) async {
    await tester.pumpWidget(_testApp(const LoginScreen()));

    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('profile onboarding renders core setup fields', (tester) async {
    await tester.pumpWidget(_testApp(const ProfileOnboardingScreen()));

    expect(find.text('Set up profile'), findsOneWidget);
    expect(find.byKey(const Key('heightField')), findsOneWidget);
    expect(find.byKey(const Key('weightField')), findsOneWidget);
    expect(find.byKey(const Key('daysPerWeekField')), findsOneWidget);
    expect(find.byKey(const Key('sessionMinutesField')), findsOneWidget);
  });

  testWidgets('generate plan screen renders start date action', (tester) async {
    await tester.pumpWidget(_testApp(const GeneratePlanScreen()));

    expect(find.text('Generate plan'), findsOneWidget);
    expect(find.byKey(const Key('chooseStartDateButton')), findsOneWidget);
    expect(find.byKey(const Key('generatePlanButton')), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  final tokenStorage = SecureTokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authService = AuthService(apiClient, tokenStorage);
  final profileService = ProfileService(apiClient);
  final workoutService = WorkoutService(apiClient);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService, profileService),
      ),
      ChangeNotifierProvider(
        create: (_) => ProfileProvider(profileService),
      ),
      ChangeNotifierProvider(
        create: (_) => WorkoutProvider(workoutService),
      ),
    ],
    child: MaterialApp(home: child),
  );
}
