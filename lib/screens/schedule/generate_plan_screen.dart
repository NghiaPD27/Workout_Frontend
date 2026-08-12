import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/workout_provider.dart';
import '../../widgets/form_error_text.dart';
import 'schedule_screen.dart';

class GeneratePlanScreen extends StatefulWidget {
  const GeneratePlanScreen({super.key});

  @override
  State<GeneratePlanScreen> createState() => _GeneratePlanScreenState();
}

class _GeneratePlanScreenState extends State<GeneratePlanScreen> {
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = _nextMonday(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Generate plan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Build this week',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'FitPlan will use your profile, goal, experience, days per week, and session duration.',
            ),
            const SizedBox(height: 20),
            FormErrorText(message: workoutProvider.errorMessage),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Start date',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(DateFormat.yMMMMEEEEd().format(_startDate)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('chooseStartDateButton'),
                      onPressed: workoutProvider.isLoading ? null : _pickStartDate,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Choose date'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              key: const Key('generatePlanButton'),
              onPressed: workoutProvider.isLoading ? null : _generate,
              icon: const Icon(Icons.auto_awesome),
              label: workoutProvider.isLoading
                  ? const Text('Generating...')
                  : const Text('Generate workout plan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateUtils.dateOnly(now),
      lastDate: DateUtils.dateOnly(now.add(const Duration(days: 60))),
      initialDate: _startDate,
    );

    if (picked != null) {
      setState(() => _startDate = DateUtils.dateOnly(picked));
    }
  }

  Future<void> _generate() async {
    final generated = await context.read<WorkoutProvider>().generatePlan(_startDate);
    if (!generated || !mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScheduleScreen()),
    );
  }

  DateTime _nextMonday(DateTime date) {
    final current = DateUtils.dateOnly(date);
    final daysUntilMonday = (DateTime.monday - current.weekday) % 7;
    return current.add(Duration(days: daysUntilMonday));
  }
}
