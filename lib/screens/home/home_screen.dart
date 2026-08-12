import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/workout_provider.dart';
import '../schedule/generate_plan_screen.dart';
import '../schedule/schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
      context.read<WorkoutProvider>().loadCurrentPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final profile = profileProvider.profile;
    final bodyOverview = profileProvider.bodyOverview;
    final plan = workoutProvider.currentPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitPlan'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Profile ready',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (profileProvider.isLoading)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile == null
                        ? 'Your profile was saved. Workout generation comes next.'
                        : '${profile.goal.label} - ${profile.daysPerWeek} days/week - ${profile.sessionMinutes} min',
                  ),
                  if (bodyOverview != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'BMI reference: ${bodyOverview.bmi.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  if (profileProvider.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      profileProvider.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan == null
                        ? 'Generate a schedule from your profile and start date.'
                        : '${plan.sessions.length} workouts ready from backend rules.',
                  ),
                  const SizedBox(height: 16),
                  if (workoutProvider.isLoading)
                    const LinearProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => plan == null
                                ? const GeneratePlanScreen()
                                : const ScheduleScreen(),
                          ),
                        );
                      },
                      icon: Icon(plan == null ? Icons.auto_awesome : Icons.calendar_month),
                      label: Text(plan == null ? 'Generate plan' : 'View schedule'),
                    ),
                  if (workoutProvider.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      workoutProvider.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
