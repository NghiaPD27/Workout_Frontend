import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../providers/workout_provider.dart';
import 'workout_session_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int sessionId;

  const WorkoutDetailScreen({super.key, required this.sessionId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadSessionDetail(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final session = workoutProvider.selectedSession;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Detail')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (workoutProvider.isLoading && session == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (session == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    workoutProvider.errorMessage ?? 'Workout was not found.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            return _WorkoutDetailContent(session: session);
          },
        ),
      ),
    );
  }
}

class _WorkoutDetailContent extends StatelessWidget {
  final WorkoutSessionDetail session;

  const _WorkoutDetailContent({required this.session});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == WorkoutSessionStatus.completed;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Session Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E265C), AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      session.status.label,
                      style: TextStyle(
                        color: isCompleted ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat.EEEE().format(session.date)} • ${session.estimatedMinutes} minutes • ${session.exercises.length} exercises',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Exercises Routine',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),

        ...session.exercises.map(
          (exercise) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    exercise.orderIndex.toString(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  exercise.prescription,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          key: const Key('startWorkoutButton'),
          onPressed: isCompleted
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutSessionScreen(session: session),
                    ),
                  );
                },
          icon: Icon(isCompleted ? Icons.check_circle_rounded : Icons.play_arrow_rounded, size: 22),
          label: Text(isCompleted ? 'Completed' : 'Start workout'),
        ),
      ],
    );
  }
}
