import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../providers/workout_provider.dart';
import 'workout_complete_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutSessionDetail session;

  const WorkoutSessionScreen({super.key, required this.session});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final DateTime _startedAt;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  int _exerciseIndex = 0;
  int _currentSet = 1;

  WorkoutExercise get _currentExercise => widget.session.exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_startedAt));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final exercise = _currentExercise;
    final totalExercises = widget.session.exercises.length;
    final progressValue = (_exerciseIndex + (_currentSet / exercise.targetSets)) / totalExercises;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_exerciseIndex + 1} / $totalExercises',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Circular Glowing Timer Ring
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF1E265C), AppColors.surface],
                    ),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.secondary, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        _formatElapsed(_elapsed),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ELAPSED TIME',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Active Exercise Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Set $_currentSet of ${exercise.targetSets}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _targetText(exercise),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Workout Session Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Session Progress', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('${(progressValue * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const Spacer(),
              if (workoutProvider.errorMessage != null) ...[
                Text(
                  workoutProvider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],

              // Complete Set / Finish Workout Button
              ElevatedButton.icon(
                key: const Key('completeSetButton'),
                onPressed: workoutProvider.isLoading ? null : _completeSetOrWorkout,
                icon: Icon(_isFinalSet ? Icons.flag_rounded : Icons.check_circle_rounded, size: 22),
                label: Text(_isFinalSet ? 'Finish Workout' : 'Complete Set'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isFinalSet {
    final finalExercise = _exerciseIndex == widget.session.exercises.length - 1;
    final finalSet = _currentSet == _currentExercise.targetSets;
    return finalExercise && finalSet;
  }

  Future<void> _completeSetOrWorkout() async {
    if (_isFinalSet) {
      final minutes = _elapsed.inMinutes < 1 ? 1 : _elapsed.inMinutes;
      final completed = await context.read<WorkoutProvider>().completeSelectedSession(
            durationMinutes: minutes,
          );
      if (completed != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WorkoutCompleteScreen(
              session: completed,
              durationMinutes: minutes,
            ),
          ),
        );
      }
      return;
    }

    final exercise = _currentExercise;
    setState(() {
      if (_currentSet < exercise.targetSets) {
        _currentSet++;
      } else {
        _exerciseIndex++;
        _currentSet = 1;
      }
    });
  }

  String _targetText(WorkoutExercise exercise) {
    if (exercise.reps != null) {
      return '${exercise.reps} reps';
    }
    if (exercise.durationSeconds != null) {
      return '${exercise.durationSeconds} seconds';
    }
    return exercise.prescription;
  }

  String _formatElapsed(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
