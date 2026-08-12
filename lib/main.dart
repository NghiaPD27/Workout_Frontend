import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/workout_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = SecureTokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authService = AuthService(apiClient, tokenStorage);
  final profileService = ProfileService(apiClient);
  final workoutService = WorkoutService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: tokenStorage),
        Provider.value(value: apiClient),
        Provider.value(value: authService),
        Provider.value(value: profileService),
        Provider.value(value: workoutService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, profileService)..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileService),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(workoutService),
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF187A6D),
          primary: const Color(0xFF187A6D),
          secondary: const Color(0xFFE2A93B),
          surface: const Color(0xFFF7FAF9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8E5)),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
