import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_token_storage.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/progress_service.dart';
import 'services/workout_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = SecureTokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authService = AuthService(apiClient, tokenStorage);
  final profileService = ProfileService(apiClient);
  final workoutService = WorkoutService(apiClient);
  final progressService = ProgressService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: tokenStorage),
        Provider.value(value: apiClient),
        Provider.value(value: authService),
        Provider.value(value: profileService),
        Provider.value(value: workoutService),
        Provider.value(value: progressService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, profileService)..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileService),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(workoutService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(progressService),
        ),
      ],
      child: const FitPlanApp(),
    ),
  );
}

class FitPlanApp extends StatelessWidget {
  const FitPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitPlan',
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}
