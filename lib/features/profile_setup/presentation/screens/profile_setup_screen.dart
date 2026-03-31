import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_colors.dart';
import 'package:abroadready/core/widgets/ar_label.dart';
import 'package:abroadready/core/widgets/ar_primary_button.dart';
import 'package:abroadready/core/widgets/ar_text_field.dart';
import 'package:abroadready/features/profile_setup/presentation/bloc/profile_setup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileSetupBloc>()..add(const ProfileSetupLoaded()),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  const _ProfileSetupView();

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();
  final _stepThreeFormKey = GlobalKey<FormState>();

  final _gpaController = TextEditingController();
  final _englishScoreController = TextEditingController();
  final _locationController = TextEditingController();

  String? _preferredDegreeType;
  String? _preferredIntakeMonth;
  String? _preferredStudyLanguage;
  String? _englishTestType;
  String? _educationLevel;
  String? _fieldOfStudy;

  int _monthlyBudget = 1200;
  int _maxTuitionPerYear = 25000;
  int _maxQsRanking = 500;
  int _maxTimesRanking = 500;

  final Set<String> _targetCountries = <String>{};
  bool _didHydrateFromState = false;

  static const List<String> _degreeTypes = <String>[
    'Bachelor\'s',
    'Master\'s',
    'PhD',
  ];

  static const List<String> _intakeMonths = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _studyLanguages = <String>[
    'English',
    'Bilingual',
    'Any',
  ];

  static const List<String> _englishTests = <String>[
    'IELTS',
    'TOEFL',
    'PTE',
    'Duolingo',
    'Not required',
  ];

  static const List<String> _educationLevels = <String>[
    'High School',
    'Bachelor\'s',
    'Master\'s+',
  ];

  static const List<String> _fieldsOfStudy = <String>[
    'Computer Science & AI',
    'Electrical Engineering',
    'Business & Management',
    'Data Science',
    'Public Health',
    'Mechanical Engineering',
    'Economics',
  ];

  static const List<String> _countries = <String>[
    'Finland',
    'Germany',
    'Sweden',
    'Netherlands',
    'Canada',
    'United States',
    'United Kingdom',
    'Australia',
  ];

  @override
  void dispose() {
    _gpaController.dispose();
    _englishScoreController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _hydrateForm(ProfileSetupState state) {
    if (_didHydrateFromState) {
      return;
    }

    final profile = state.profile;
    _preferredDegreeType = profile.preferredDegreeType.isEmpty
        ? null
        : profile.preferredDegreeType;
    _preferredIntakeMonth = profile.preferredIntakeMonth.isEmpty
        ? null
        : profile.preferredIntakeMonth;
    _preferredStudyLanguage = profile.preferredStudyLanguage.isEmpty
        ? null
        : profile.preferredStudyLanguage;
    _englishTestType = profile.englishTestType.isEmpty
        ? null
        : profile.englishTestType;
    _educationLevel = profile.currentEducationLevel.isEmpty
        ? null
        : profile.currentEducationLevel;
    _fieldOfStudy = profile.fieldOfStudy.isEmpty ? null : profile.fieldOfStudy;

    _monthlyBudget = profile.monthlyLivingBudgetEur;
    _maxTuitionPerYear = profile.maxTuitionPerYearEur;
    _maxQsRanking = profile.maxQsRanking;
    _maxTimesRanking = profile.maxTimesRanking;

    _targetCountries
      ..clear()
      ..addAll(profile.targetCountries);

    if (profile.cumulativeGpa > 0) {
      _gpaController.text = profile.cumulativeGpa.toStringAsFixed(2);
    }
    if (profile.englishTestScore > 0) {
      _englishScoreController.text = profile.englishTestScore.toStringAsFixed(
        1,
      );
    }
    _locationController.text = profile.currentLocationCountry;

    _didHydrateFromState = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupBloc, ProfileSetupState>(
      listener: (context, state) {
        if (state.status == ProfileSetupSubmissionStatus.success) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        }

        if (state.status == ProfileSetupSubmissionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        _hydrateForm(state);

        final isBusy =
            state.status == ProfileSetupSubmissionStatus.loading ||
            state.status == ProfileSetupSubmissionStatus.saving;

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile Setup - Step ${state.currentStep}'),
            leading: state.currentStep > 1
                ? IconButton(
                    onPressed: isBusy
                        ? null
                        : () => context.read<ProfileSetupBloc>().add(
                            const ProfileSetupPreviousStepPressed(),
                          ),
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${state.currentStep} of 3',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    minHeight: 5,
                    value: state.currentStep / 3,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 26),
                  if (state.currentStep == 1) _buildStepOne(context, isBusy),
                  if (state.currentStep == 2) _buildStepTwo(context, isBusy),
                  if (state.currentStep == 3) _buildStepThree(context, isBusy),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepOne(BuildContext context, bool isBusy) {
    return Form(
      key: _stepOneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Study Goals', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(
            'Tell us what kind of program you are looking for.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const ArLabel('Preferred Degree Type'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _preferredDegreeType,
            items: _degreeTypes
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _preferredDegreeType = value),
            decoration: const InputDecoration(hintText: 'Select degree type'),
            validator: (value) =>
                value == null ? 'Please select degree type' : null,
          ),
          const SizedBox(height: 16),
          const ArLabel('Preferred Intake Month'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _preferredIntakeMonth,
            items: _intakeMonths
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _preferredIntakeMonth = value),
            decoration: const InputDecoration(hintText: 'Select intake month'),
            validator: (value) =>
                value == null ? 'Please select intake month' : null,
          ),
          const SizedBox(height: 16),
          const ArLabel('Preferred Study Language'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _preferredStudyLanguage,
            items: _studyLanguages
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _preferredStudyLanguage = value),
            decoration: const InputDecoration(
              hintText: 'Select preferred language',
            ),
            validator: (value) =>
                value == null ? 'Please select preferred language' : null,
          ),
          const SizedBox(height: 28),
          ArPrimaryButton(
            label: 'Continue',
            isLoading: isBusy,
            onPressed: isBusy ? null : () => _submitStepOne(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTwo(BuildContext context, bool isBusy) {
    return Form(
      key: _stepTwoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Background',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Share your scores so we can filter programs that fit your profile.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const ArLabel('Cumulative GPA'),
          const SizedBox(height: 8),
          ArTextField(
            controller: _gpaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: 'e.g. 3.85',
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null) {
                return 'Enter a valid GPA';
              }
              if (parsed < 0 || parsed > 4) {
                return 'GPA should be between 0 and 4.0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const ArLabel('English Test Type'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _englishTestType,
            items: _englishTests
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _englishTestType = value),
            decoration: const InputDecoration(hintText: 'Select test type'),
            validator: (value) =>
                value == null ? 'Please select English test type' : null,
          ),
          const SizedBox(height: 16),
          const ArLabel('Overall Score'),
          const SizedBox(height: 8),
          ArTextField(
            controller: _englishScoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: 'Enter score',
            validator: (value) {
              final type = _englishTestType;
              if (type == null) {
                return 'Select test type first';
              }
              if (type == 'Not required') {
                return null;
              }
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid score';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const ArLabel('Current Level of Education'),
          const SizedBox(height: 10),
          ..._educationLevels.map(
            (level) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectableBox(
                label: level,
                selected: _educationLevel == level,
                onTap: isBusy
                    ? null
                    : () => setState(() => _educationLevel = level),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ArPrimaryButton(
            label: 'Continue',
            isLoading: isBusy,
            onPressed: isBusy ? null : () => _submitStepTwo(context),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: isBusy
                ? null
                : () => context.read<ProfileSetupBloc>().add(
                    const ProfileSetupPreviousStepPressed(),
                  ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepThree(BuildContext context, bool isBusy) {
    return Form(
      key: _stepThreeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Preferences',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Finalize your profile to receive curated program recommendations.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const ArLabel('Monthly Budget'),
              const Spacer(),
              Text(
                '€$_monthlyBudget /mo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryIndigo,
                ),
              ),
            ],
          ),
          Slider(
            value: _monthlyBudget.toDouble(),
            min: 200,
            max: 5000,
            divisions: 48,
            onChanged: isBusy
                ? null
                : (value) => setState(() => _monthlyBudget = value.round()),
          ),
          const SizedBox(height: 10),
          const ArLabel('Target Countries'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _countries
                .map(
                  (country) => FilterChip(
                    label: Text(country),
                    selected: _targetCountries.contains(country),
                    onSelected: isBusy
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected) {
                                _targetCountries.add(country);
                              } else {
                                _targetCountries.remove(country);
                              }
                            });
                          },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const ArLabel('Field of Study'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _fieldOfStudy,
            items: _fieldsOfStudy
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _fieldOfStudy = value),
            decoration: const InputDecoration(hintText: 'Select field'),
            validator: (value) =>
                value == null ? 'Please select a field of study' : null,
          ),
          const SizedBox(height: 16),
          const ArLabel('Current Location'),
          const SizedBox(height: 8),
          ArTextField(
            controller: _locationController,
            hintText: 'e.g. United States',
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Current location is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const ArLabel('Maximum Tuition Per Year (EUR)'),
          const SizedBox(height: 8),
          Slider(
            value: _maxTuitionPerYear.toDouble(),
            min: 0,
            max: 60000,
            divisions: 60,
            label: '€$_maxTuitionPerYear',
            onChanged: isBusy
                ? null
                : (value) => setState(() => _maxTuitionPerYear = value.round()),
          ),
          Text(
            '€$_maxTuitionPerYear',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const ArLabel('Maximum QS Ranking'),
          const SizedBox(height: 8),
          Slider(
            value: _maxQsRanking.toDouble(),
            min: 50,
            max: 1000,
            divisions: 95,
            label: _maxQsRanking.toString(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _maxQsRanking = value.round()),
          ),
          const SizedBox(height: 8),
          const ArLabel('Maximum Times Ranking'),
          const SizedBox(height: 8),
          Slider(
            value: _maxTimesRanking.toDouble(),
            min: 50,
            max: 1000,
            divisions: 95,
            label: _maxTimesRanking.toString(),
            onChanged: isBusy
                ? null
                : (value) => setState(() => _maxTimesRanking = value.round()),
          ),
          const SizedBox(height: 22),
          ArPrimaryButton(
            label: 'Complete Profile',
            isLoading: isBusy,
            onPressed: isBusy ? null : () => _submitStepThree(context),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: isBusy
                ? null
                : () => context.read<ProfileSetupBloc>().add(
                    const ProfileSetupPreviousStepPressed(),
                  ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  void _submitStepOne(BuildContext context) {
    if (!(_stepOneFormKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ProfileSetupBloc>().add(
      ProfileSetupStepOneSubmitted(
        preferredDegreeType: _preferredDegreeType!,
        preferredIntakeMonth: _preferredIntakeMonth!,
        preferredStudyLanguage: _preferredStudyLanguage!,
      ),
    );
  }

  void _submitStepTwo(BuildContext context) {
    if (_educationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your education level.')),
      );
      return;
    }

    if (!(_stepTwoFormKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ProfileSetupBloc>().add(
      ProfileSetupStepTwoSubmitted(
        cumulativeGpa: double.parse(_gpaController.text.trim()),
        englishTestType: _englishTestType!,
        englishTestScore: _englishTestType == 'Not required'
            ? 0
            : double.parse(_englishScoreController.text.trim()),
        currentEducationLevel: _educationLevel!,
      ),
    );
  }

  void _submitStepThree(BuildContext context) {
    if (_targetCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one country.')),
      );
      return;
    }

    if (!(_stepThreeFormKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ProfileSetupBloc>().add(
      ProfileSetupStepThreeSubmitted(
        monthlyLivingBudgetEur: _monthlyBudget,
        targetCountries: _targetCountries.toList()..sort(),
        fieldOfStudy: _fieldOfStudy!,
        currentLocationCountry: _locationController.text.trim(),
        maxTuitionPerYearEur: _maxTuitionPerYear,
        maxQsRanking: _maxQsRanking,
        maxTimesRanking: _maxTimesRanking,
      ),
    );
  }
}

class _SelectableBox extends StatelessWidget {
  const _SelectableBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryIndigo.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryIndigo : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.school_outlined,
              color: selected
                  ? AppColors.primaryIndigo
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
