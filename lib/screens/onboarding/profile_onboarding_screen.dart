import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/form_error_text.dart';

class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() => _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '65');
  final _daysController = TextEditingController(text: '3');
  final _minutesController = TextEditingController(text: '30');
  DateTime? _birthDate;
  ActivityLevel _activityLevel = ActivityLevel.low;
  ExperienceLevel _experienceLevel = ExperienceLevel.beginner;
  FitnessGoal _goal = FitnessGoal.improveFitness;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _daysController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up profile'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: profileProvider.isLoading
                ? null
                : () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your starting point',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'FitPlan uses this to generate practical workouts from the backend.',
                    ),
                    const SizedBox(height: 20),
                    FormErrorText(message: profileProvider.errorMessage),
                    OutlinedButton.icon(
                      key: const Key('birthDateButton'),
                      onPressed: _pickBirthDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _birthDate == null
                            ? 'Choose birth date'
                            : DateFormat.yMMMd().format(_birthDate!),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('heightField'),
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Height (cm)'),
                            validator: (value) => _validateInt(value, 80, 250),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const Key('weightField'),
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Weight (kg)'),
                            validator: _validateWeight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _EnumDropdown<ActivityLevel>(
                      label: 'Activity level',
                      value: _activityLevel,
                      values: ActivityLevel.values,
                      labelBuilder: (value) => value.label,
                      onChanged: (value) => setState(() => _activityLevel = value),
                    ),
                    const SizedBox(height: 14),
                    _EnumDropdown<ExperienceLevel>(
                      label: 'Training experience',
                      value: _experienceLevel,
                      values: ExperienceLevel.values,
                      labelBuilder: (value) => value.label,
                      onChanged: (value) => setState(() => _experienceLevel = value),
                    ),
                    const SizedBox(height: 14),
                    _EnumDropdown<FitnessGoal>(
                      label: 'Goal',
                      value: _goal,
                      values: FitnessGoal.values,
                      labelBuilder: (value) => value.label,
                      onChanged: (value) => setState(() => _goal = value),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('daysPerWeekField'),
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Days/week'),
                            validator: (value) => _validateInt(value, 1, 7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const Key('sessionMinutesField'),
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Minutes/session'),
                            validator: (value) => _validateInt(value, 10, 180),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      key: const Key('profileSubmitButton'),
                      onPressed: profileProvider.isLoading ? null : _submit,
                      child: profileProvider.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      initialDate: _birthDate ?? DateTime(now.year - 24, now.month, now.day),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = ProfilePayload(
      birthDate: _birthDate,
      heightCm: int.parse(_heightController.text),
      weightKg: double.parse(_weightController.text),
      activityLevel: _activityLevel,
      experienceLevel: _experienceLevel,
      goal: _goal,
      daysPerWeek: int.parse(_daysController.text),
      sessionMinutes: int.parse(_minutesController.text),
    );

    final saved = await context.read<ProfileProvider>().saveProfile(payload);
    if (saved && mounted) {
      await context.read<AuthProvider>().markProfileComplete();
    }
  }

  String? _validateInt(String? value, int min, int max) {
    final number = int.tryParse(value ?? '');
    if (number == null) {
      return 'Required';
    }
    if (number < min || number > max) {
      return '$min-$max';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final number = double.tryParse(value ?? '');
    if (number == null) {
      return 'Required';
    }
    if (number < 20 || number > 300) {
      return '20-300';
    }
    return null;
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
