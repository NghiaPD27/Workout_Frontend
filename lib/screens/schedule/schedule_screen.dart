import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/workout_plan.dart';
import '../../providers/workout_provider.dart';
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
        title: const Text('Weekly schedule'),
        actions: [
          IconButton(
            tooltip: 'Generate new plan',
            onPressed: workoutProvider.isLoading
                ? null
                : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GeneratePlanScreen()),
                    ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (workoutProvider.isLoading && plan == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (workoutProvider.errorMessage != null && plan == null) {
              return _ScheduleMessage(
                icon: Icons.error_outline,
                title: 'Could not load schedule',
                message: workoutProvider.errorMessage!,
                actionLabel: 'Try again',
                onAction: workoutProvider.loadCurrentPlan,
              );
            }

            if (plan == null) {
              return _ScheduleMessage(
                icon: Icons.calendar_month,
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
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Week of ${DateFormat.MMMd().format(plan.startDate)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${DateFormat.MMMd().format(plan.startDate)} - ${DateFormat.MMMd().format(plan.endDate)}',
          style: const TextStyle(color: Colors.black54),
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
            return Expanded(
              child: AspectRatio(
                aspectRatio: 0.8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: session == null
                        ? const Color(0xFFF2F5F4)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8E5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdayLabel(weekday),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          session == null ? Icons.remove : Icons.check_circle,
                          size: 18,
                          color: session == null
                              ? Colors.black38
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(_iconFor(session.workoutType), color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(session.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${DateFormat.EEEE().format(session.date)} - ${session.duration} min - ${session.status.label}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: null,
      ),
    );
  }

  IconData _iconFor(WorkoutType type) {
    return switch (type) {
      WorkoutType.upper => Icons.accessibility_new,
      WorkoutType.lower => Icons.directions_run,
      WorkoutType.core => Icons.center_focus_strong,
      WorkoutType.fullBody => Icons.fitness_center,
      WorkoutType.cardio => Icons.favorite,
      WorkoutType.mobility => Icons.self_improvement,
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
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
