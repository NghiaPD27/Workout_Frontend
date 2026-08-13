import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../providers/workout_provider.dart';
import '../workout/workout_detail_screen.dart';
import 'generate_plan_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadCurrentPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final plan = workoutProvider.currentPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        actions: [
          IconButton(
            tooltip: 'Generate new plan',
            onPressed: workoutProvider.isLoading
                ? null
                : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GeneratePlanScreen()),
                    ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (workoutProvider.isLoading && plan == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (workoutProvider.errorMessage != null && plan == null) {
              return _ScheduleMessage(
                icon: Icons.error_outline_rounded,
                title: 'Could not load schedule',
                message: workoutProvider.errorMessage!,
                actionLabel: 'Try again',
                onAction: workoutProvider.loadCurrentPlan,
              );
            }

            if (plan == null) {
              return _ScheduleMessage(
                icon: Icons.calendar_month_rounded,
                title: 'No plan yet',
                message: 'Generate your first weekly plan from your saved profile.',
                actionLabel: 'Generate plan',
                onAction: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GeneratePlanScreen()),
                ),
              );
            }

            return _ScheduleContent(plan: plan);
          },
        ),
      ),
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  final WorkoutPlan plan;

  const _ScheduleContent({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week of ${DateFormat.MMMd().format(plan.startDate)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat.MMMd().format(plan.startDate)} - ${DateFormat.MMMd().format(plan.endDate)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${plan.sessions.length} Sessions',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _WeekStrip(sessions: plan.sessions),
        const SizedBox(height: 20),
        ...plan.sessions.map((session) => _SessionCard(session: session)),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<WorkoutSessionSummary> sessions;

  const _WeekStrip({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final sessionByWeekday = {
      for (final session in sessions) session.date.weekday: session,
    };
    const weekdays = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: weekdays.map((weekday) {
            final session = sessionByWeekday[weekday];
            final hasSession = session != null;
            final isCompleted = session?.status == WorkoutSessionStatus.completed;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : (hasSession ? AppColors.primaryContainer : AppColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasSession ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayLabel(weekday),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isCompleted
                            ? Colors.white
                            : (hasSession ? AppColors.primary : AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : (hasSession ? Icons.fitness_center_rounded : Icons.remove_rounded),
                      size: 16,
                      color: isCompleted
                          ? Colors.white
                          : (hasSession ? AppColors.primary : AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'M',
      DateTime.tuesday => 'T',
      DateTime.wednesday => 'W',
      DateTime.thursday => 'T',
      DateTime.friday => 'F',
      DateTime.saturday => 'S',
      DateTime.sunday => 'S',
      _ => '',
    };
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSessionSummary session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == WorkoutSessionStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _iconFor(session.workoutType),
            color: isCompleted ? AppColors.success : AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          session.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${DateFormat.EEEE().format(session.date)} • ${session.duration} min',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withOpacity(0.15)
                : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.status.label,
                style: TextStyle(
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: isCompleted ? AppColors.success : AppColors.primary,
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(sessionId: session.id),
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(WorkoutType type) {
    return switch (type) {
      WorkoutType.upper => Icons.accessibility_new_rounded,
      WorkoutType.lower => Icons.directions_run_rounded,
      WorkoutType.core => Icons.center_focus_strong_rounded,
      WorkoutType.fullBody => Icons.fitness_center_rounded,
      WorkoutType.cardio => Icons.favorite_rounded,
      WorkoutType.mobility => Icons.self_improvement_rounded,
    };
  }
}

class _ScheduleMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _ScheduleMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
