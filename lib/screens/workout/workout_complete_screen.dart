import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  final WorkoutSessionDetail session;
  final int durationMinutes;

  const WorkoutCompleteScreen({
    super.key,
    required this.session,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Workout Complete! 🎉',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Great job! ${session.name} finished in $durationMinutes minutes.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home_rounded, size: 20),
                    label: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
