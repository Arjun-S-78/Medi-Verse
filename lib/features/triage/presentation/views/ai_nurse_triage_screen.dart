import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/severity_level.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Clinical AI Nurse Triage Screen (Hospital Triage Nurse Protocol)
/// Feature-First Clean Architecture: Presentation Layer
class AiNurseTriageScreen extends StatefulWidget {
  const AiNurseTriageScreen({super.key});

  @override
  State<AiNurseTriageScreen> createState() => _AiNurseTriageScreenState();
}

class _AiNurseTriageScreenState extends State<AiNurseTriageScreen> {
  // Triage Phase: 0 = Welcome, 1-4 = Questions, 5 = Processing, 6 = Result
  int _currentPhase = 0;
  int _currentQuestionIndex = 0;
  bool _isListeningVoice = false;

  // Question Form Data
  int _selectedCategoryIndex = 0;
  double _painLevel = 7.0;
  final Set<String> _associatedSymptoms = {'Shortness of Breath', 'Sweating'};
  int _breathingScoreIndex = 0;

  final List<Map<String, dynamic>> _symptomCategories = [
    {
      'title': 'Chest & Cardiac',
      'subtitle': 'Pressure, tightness, radiating pain',
      'icon': Icons.favorite_outlined,
      'color': AppColors.esi1Critical,
    },
    {
      'title': 'Respiratory & Lungs',
      'subtitle': 'Wheezing, gasping, shortness of breath',
      'icon': Icons.air_rounded,
      'color': AppColors.esi2Emergent,
    },
    {
      'title': 'Neurological & Head',
      'subtitle': 'Severe headache, numbness, confusion',
      'icon': Icons.psychology_rounded,
      'color': AppColors.secondary500,
    },
    {
      'title': 'Abdominal & Visceral',
      'subtitle': 'Acute pain, nausea, vomiting',
      'icon': Icons.medical_services_outlined,
      'color': AppColors.esi3Urgent,
    },
    {
      'title': 'Trauma & Bleeding',
      'subtitle': 'Laceration, fracture, severe bleed',
      'icon': Icons.bloodtype_rounded,
      'color': AppColors.esi1Critical,
    },
  ];

  final List<String> _associatedSymptomOptions = [
    'Shortness of Breath',
    'Cold Sweating',
    'Dizziness / Lightheaded',
    'Arm or Jaw Pain',
    'Nausea / Vomiting',
    'Palpitations',
    'Confusion',
  ];

  final List<String> _breathingOptions = [
    'Breathing Normally (Full sentences)',
    'Moderate Distress (Short sentences)',
    'Severe Gasping (Single words only)',
    'Unable to Speak (Critical Airway)',
  ];

  void _nextQuestion() {
    if (_currentQuestionIndex < 3) {
      setState(() => _currentQuestionIndex++);
    } else {
      _startRiskProcessing();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    } else {
      setState(() => _currentPhase = 0);
    }
  }

  void _startRiskProcessing() async {
    setState(() => _currentPhase = 5); // Processing Phase
    await Future.delayed(const Duration(milliseconds: 2600));
    if (mounted) {
      setState(() => _currentPhase = 6); // Result Phase
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (_currentPhase > 0 && _currentPhase < 5) {
              _previousQuestion();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
        title: Text(
          _currentPhase == 0
              ? 'AI Nurse Triage'
              : (_currentPhase < 5
                  ? 'Clinical Assessment'
                  : (_currentPhase == 5 ? 'Processing Risk...' : 'Triage Result')),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildCurrentPhaseWidget(isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentPhaseWidget(bool isDark) {
    switch (_currentPhase) {
      case 0:
        return _buildTriageWelcomeView(isDark);
      case 1:
      case 2:
      case 3:
      case 4:
        return _buildQuestionCardView(isDark);
      case 5:
        return _buildRiskProcessingView(isDark);
      case 6:
        return _buildTriageResultView(isDark);
      default:
        return _buildTriageWelcomeView(isDark);
    }
  }

  // ==========================================
  // PHASE 0: TRIAGE WELCOME SCREEN
  // ==========================================
  Widget _buildTriageWelcomeView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('WelcomeView'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Nurse Sarah Avatar Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary500.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary500, AppColors.primary600],
                      ),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.esi4LessUrgent,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 500.ms),

              const SizedBox(height: 20),

              const Text(
                'Nurse Sarah, RN (AI)',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Certified Emergency Triage Specialist',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary500,
                ),
              ),

              const SizedBox(height: 24),

              // Overview Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Welcome to AI Emergency Triage',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'I will guide you through 4 clinical questions to evaluate your emergency risk against the Manchester Triage Index (ESI 1-5) and match you with an ER & ambulance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.neutral600, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Live Vitals Preview Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary100.withValues(alpha: isDark ? 0.1 : 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary500.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined, color: AppColors.secondary500, size: 26),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connected Vitals Sync',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary500),
                          ),
                          Text(
                            'Heart Rate: 88 BPM • SpO2: 97%',
                            style: TextStyle(fontSize: 12, color: AppColors.neutral700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Begin Triage Assessment',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  setState(() {
                    _currentPhase = 1;
                    _currentQuestionIndex = 0;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PHASE 1-4: QUESTION CARDS VIEW
  // ==========================================
  Widget _buildQuestionCardView(bool isDark) {
    final double progress = (_currentQuestionIndex + 1) / 4.0;

    return SingleChildScrollView(
      key: ValueKey('QuestionView_$_currentQuestionIndex'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentQuestionIndex + 1} of 4',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% Completed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.neutral200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary500),
                ),
              ),

              const SizedBox(height: 24),

              // Voice Input Pulse Banner Button
              GestureDetector(
                onTap: () {
                  setState(() => _isListeningVoice = !_isListeningVoice);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isListeningVoice
                        ? AppColors.secondary500
                        : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary500,
                      width: 1.5,
                    ),
                    boxShadow: _isListeningVoice
                        ? [
                            BoxShadow(
                              color: AppColors.secondary500.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isListeningVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListeningVoice ? Colors.white : AppColors.secondary500,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isListeningVoice
                              ? 'Nurse Sarah listening... Speak symptoms'
                              : 'Tap to speak symptoms hands-free',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isListeningVoice ? Colors.white : AppColors.secondary500,
                          ),
                        ),
                      ),
                      if (_isListeningVoice)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Question Card Dynamic Render
              _buildQuestionCardContent(isDark),

              const SizedBox(height: 32),

              // Navigation Buttons Row (Previous & Next)
              Row(
                children: [
                  if (_currentQuestionIndex > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _previousQuestion,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: _currentQuestionIndex == 3 ? 'Process Triage Risk' : 'Next Question',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _nextQuestion,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Question Card Specific Content Renderer
  Widget _buildQuestionCardContent(bool isDark) {
    switch (_currentQuestionIndex) {
      case 0:
        // Question 1: Symptom Location Category
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question 1',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Where is your primary symptom located?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...List.generate(_symptomCategories.length, (index) {
              final item = _symptomCategories[index];
              final isSelected = _selectedCategoryIndex == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (item['color'] as Color).withValues(alpha: 0.12)
                          : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? (item['color'] as Color) : (isDark ? AppColors.darkBorder : AppColors.neutral200),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                item['subtitle'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: item['color'] as Color, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      case 1:
        // Question 2: Pain Intensity Rating (Visual 0-10 Scale)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question 2',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Rate your pain level right now (0 to 10):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
              ),
              child: Column(
                children: [
                  Text(
                    '${_painLevel.toInt()} / 10',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _getPainColor(_painLevel),
                    ),
                  ),
                  Text(
                    _getPainDescription(_painLevel),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getPainColor(_painLevel),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _painLevel,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: _getPainColor(_painLevel),
                    onChanged: (val) => setState(() => _painLevel = val),
                  ),
                ],
              ),
            ),
          ],
        );

      case 2:
        // Question 3: Associated High-Risk Symptoms
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question 3',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select any associated high-risk signs:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _associatedSymptomOptions.map((option) {
                final isSelected = _associatedSymptoms.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: AppColors.primary500.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary500,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary500
                        : (isDark ? AppColors.neutral400 : AppColors.neutral700),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _associatedSymptoms.add(option);
                      } else {
                        _associatedSymptoms.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        // Question 4: Breathing & Airway Check
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question 4',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary500),
            ),
            const SizedBox(height: 4),
            const Text(
              'How is your breathing right now?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...List.generate(_breathingOptions.length, (index) {
              final isSelected = _breathingScoreIndex == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _breathingScoreIndex = index),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withValues(alpha: 0.12)
                          : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary500 : (isDark ? AppColors.darkBorder : AppColors.neutral200),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? AppColors.primary500 : AppColors.neutral400,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _breathingOptions[index],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Color _getPainColor(double level) {
    if (level < 4) return AppColors.esi4LessUrgent;
    if (level < 7) return AppColors.esi3Urgent;
    return AppColors.esi1Critical;
  }

  String _getPainDescription(double level) {
    if (level == 0) return 'No Pain';
    if (level < 4) return 'Mild Discomfort';
    if (level < 7) return 'Moderate Distress';
    if (level < 9) return 'Severe Acute Pain';
    return 'Worst Imaginable Emergency Pain';
  }

  // ==========================================
  // PHASE 5: RISK PROCESSING ANIMATION
  // ==========================================
  Widget _buildRiskProcessingView(bool isDark) {
    return Center(
      key: const ValueKey('ProcessingView'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radar Scan Pulse Visualizer
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary500.withValues(alpha: 0.15),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.3, 1.3), duration: 1000.ms),

                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary500,
                  ),
                  child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 48),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Calculating Clinical Emergency Risk...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Evaluating Manchester Triage Index (ESI 1-5) & matching nearby ER trauma beds.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PHASE 6: TRIAGE RESULT VIEW
  // ==========================================
  Widget _buildTriageResultView(bool isDark) {
    final EsiSeverityLevel level = EsiSeverityLevel.esi1;

    return SingleChildScrollView(
      key: const ValueKey('ResultView'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ESI 1 Emergency Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: level.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: level.color, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: level.color,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESI LEVEL ${level.level}: ${level.name.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: level.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Immediate Life Threat - Cardiac Protocol Required',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      level.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.neutral700, height: 1.3),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 500.ms),

              const SizedBox(height: 20),

              // Matched Destination Hospital Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_hospital_outlined, color: AppColors.primary500, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City General Hospital ER',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Trauma Center Level 1 • 1.2 km away',
                            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '4 ICU Beds',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.esi4LessUrgent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dispatch Primary CTA
              PrimaryButton(
                text: 'DISPATCH AMBULANCE & LOCK ER BED',
                backgroundColor: AppColors.esi1Critical,
                textColor: Colors.white,
                icon: Icons.airport_shuttle_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dispatching ALS Unit #402 & Reserving ICU Bed...'),
                      backgroundColor: AppColors.esi1Critical,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go(RouteNames.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
