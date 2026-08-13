import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/progress.dart';
import '../../providers/progress_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final summary = progressProvider.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Progress')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (progressProvider.isLoading && summary == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (summary == null) {
              return _ProgressMessage(
                message: progressProvider.errorMessage ?? 'No progress yet.',
                onRetry: progressProvider.loadProgress,
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: progressProvider.loadProgress,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _FitnessScoreCard(summary: summary),
                  const SizedBox(height: 16),
                  _StatsGrid(summary: summary),
                  const SizedBox(height: 16),
                  _ScoreBreakdown(summary: summary),
                  const SizedBox(height: 16),
                  _WeeklyChart(weeklyProgress: progressProvider.weeklyProgress),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FitnessScoreCard extends StatelessWidget {
  final ProgressSummary summary;

  const _FitnessScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final delta = summary.scoreDelta;
    final deltaText = delta == 0 ? 'No change' : '${delta > 0 ? '+' : ''}$delta';

    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fitness Score',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${summary.fitnessScore}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 42,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/100',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  delta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  deltaText,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ProgressSummary summary;

  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.7,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatTile(
          label: 'Workouts',
          value: '${summary.completedWorkouts}/${summary.plannedWorkouts}',
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.primary,
        ),
        _StatTile(
          label: 'Minutes',
          value: '${summary.totalWorkoutMinutes}',
          icon: Icons.timer_rounded,
          iconColor: AppColors.secondary,
        ),
        _StatTile(
          label: 'Streak',
          value: '${summary.currentStreak} days',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFFF7A00),
        ),
        _StatTile(
          label: 'Recovery',
          value: '${summary.recoveryScore}',
          icon: Icons.nightlight_round,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final ProgressSummary summary;

  const _ScoreBreakdown({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _ScoreBar(label: 'Workout', value: summary.workoutScore),
            _ScoreBar(label: 'Consistency', value: summary.consistencyScore),
            _ScoreBar(label: 'Activity', value: summary.activityScore),
            _ScoreBar(label: 'Recovery', value: summary.recoveryScore),
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '$value / 100',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<WeeklyProgress> weeklyProgress;

  const _WeeklyChart({required this.weeklyProgress});

  @override
  Widget build(BuildContext context) {
    if (weeklyProgress.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Weekly history will appear after your first completed workout.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final spots = weeklyProgress.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.fitnessScore.toDouble());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat.MMMd().format(weeklyProgress.first.weekStart)} - ${DateFormat.MMMd().format(weeklyProgress.last.weekStart)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.border.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3.5,
                      color: AppColors.primary,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressMessage extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProgressMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
