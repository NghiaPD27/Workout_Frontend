import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/form_error_text.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? initialProfile;

  const EditProfileScreen({super.key, this.initialProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _daysController;
  late final TextEditingController _minutesController;
  late DateTime? _birthDate;
  late ActivityLevel _activityLevel;
  late ExperienceLevel _experienceLevel;
  late FitnessGoal _goal;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _heightController = TextEditingController(
      text: '${profile?.heightCm ?? 170}',
    );
    _weightController = TextEditingController(
      text: _formatWeight(profile?.weightKg ?? 65.0),
    );
    _daysController = TextEditingController(
      text: '${profile?.daysPerWeek ?? 3}',
    );
    _minutesController = TextEditingController(
      text: '${profile?.sessionMinutes ?? 30}',
    );
    _birthDate = profile?.birthDate;
    _activityLevel = profile?.activityLevel ?? ActivityLevel.low;
    _experienceLevel = profile?.experienceLevel ?? ExperienceLevel.beginner;
    _goal = profile?.goal ?? FitnessGoal.improveFitness;
  }

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
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E265C), AppColors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tune your plan',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Update your stats and training preferences so future plans stay useful.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FormErrorText(message: profileProvider.errorMessage),
                    OutlinedButton.icon(
                      key: const Key('editBirthDateButton'),
                      onPressed: profileProvider.isLoading
                          ? null
                          : _pickBirthDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 20),
                      label: Text(
                        _birthDate == null
                            ? 'Choose birth date'
                            : DateFormat.yMMMd().format(_birthDate!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('editHeightField'),
                            controller: _heightController,
                            enabled: !profileProvider.isLoading,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              prefixIcon: Icon(Icons.height_rounded),
                            ),
                            validator: (value) => _validateInt(value, 80, 250),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const Key('editWeightField'),
                            controller: _weightController,
                            enabled: !profileProvider.isLoading,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(Icons.monitor_weight_outlined),
                            ),
                            validator: _validateWeight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _EnumDropdown<ActivityLevel>(
                      label: 'Activity Level',
                      value: _activityLevel,
                      values: ActivityLevel.values,
                      enabled: !profileProvider.isLoading,
                      labelBuilder: (value) => value.label,
                      onChanged: (value) =>
                          setState(() => _activityLevel = value),
                    ),
                    const SizedBox(height: 16),
                    _EnumDropdown<ExperienceLevel>(
                      label: 'Training Experience',
                      value: _experienceLevel,
                      values: ExperienceLevel.values,
                      enabled: !profileProvider.isLoading,
                      labelBuilder: (value) => value.label,
                      onChanged: (value) =>
                          setState(() => _experienceLevel = value),
                    ),
                    const SizedBox(height: 16),
                    _EnumDropdown<FitnessGoal>(
                      label: 'Fitness Goal',
                      value: _goal,
                      values: FitnessGoal.values,
                      enabled: !profileProvider.isLoading,
                      labelBuilder: (value) => value.label,
                      onChanged: (value) => setState(() => _goal = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('editDaysPerWeekField'),
                            controller: _daysController,
                            enabled: !profileProvider.isLoading,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Days / Week',
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                            ),
                            validator: (value) => _validateInt(value, 1, 7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const Key('editSessionMinutesField'),
                            controller: _minutesController,
                            enabled: !profileProvider.isLoading,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min / Session',
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            validator: (value) => _validateInt(value, 10, 180),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      key: const Key('editProfileSubmitButton'),
                      onPressed: profileProvider.isLoading ? null : _submit,
                      child: profileProvider.isLoading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Profile'),
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
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = ProfilePayload(
      birthDate: _birthDate,
      heightCm: int.parse(_heightController.text.trim()),
      weightKg: double.parse(_weightController.text.trim()),
      activityLevel: _activityLevel,
      experienceLevel: _experienceLevel,
      goal: _goal,
      daysPerWeek: int.parse(_daysController.text.trim()),
      sessionMinutes: int.parse(_minutesController.text.trim()),
    );

    final saved = await context.read<ProfileProvider>().saveProfile(payload);
    if (saved && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _formatWeight(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
  }

  String? _validateInt(String? value, int min, int max) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) {
      return 'Required';
    }
    if (number < min || number > max) {
      return '$min-$max';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
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
  final bool enabled;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.enabled,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: AppColors.surfaceVariant,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (value) {
              if (value != null) {
                onChanged(value);
              }
            }
          : null,
    );
  }
}
