import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
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
      appBar: AppBar(title: const Text('Generate Plan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
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
                  Text(
                    'Build This Week ✨',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FitPlan will use your profile, goal, experience, days per week, and session duration to construct an ideal schedule.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FormErrorText(message: workoutProvider.errorMessage),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Start Date',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DateFormat.yMMMMEEEEd().format(_startDate),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('chooseStartDateButton'),
                      onPressed: workoutProvider.isLoading ? null : _pickStartDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: const Text('Choose date'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('generatePlanButton'),
              onPressed: workoutProvider.isLoading ? null : _generate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: workoutProvider.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
