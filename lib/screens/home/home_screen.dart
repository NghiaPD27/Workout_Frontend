import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final bodyOverview = profileProvider.bodyOverview;

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
                        : '${profile.goal.label} • ${profile.daysPerWeek} days/week • ${profile.sessionMinutes} min',
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
                    'Next milestone',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Phase 3 will connect the backend workout generator and weekly schedule.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Generate plan soon'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
