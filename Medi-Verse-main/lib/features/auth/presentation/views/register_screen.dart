import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

/// Premium Enterprise Registration Screen (Health Passport Setup)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // State Variables
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _medicalConditionsOptions = [
    'Diabetes',
    'Asthma',
    'Hypertension',
    'Heart Condition',
    'Penicillin Allergy',
    'Epilepsy',
    'None',
  ];
  final Set<String> _selectedConditions = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the Terms & Conditions to proceed.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.esi2Emergent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Emergency Health Profile Created Successfully!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.esi4LessUrgent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(RouteNames.home);
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
          onPressed: () => context.go(RouteNames.login),
        ),
        title: Text(
          'Create Health Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Branding Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary500.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: isDark ? AppColors.neutral900 : Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Health Passport',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Data encrypted for instant paramedic & ER access',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark ? AppColors.neutral400 : AppColors.neutral700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // Registration Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Personal Identity
                        _buildSectionHeader('1. Personal Identity', isDark),

                        // Full Name Field
                        CustomTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hintText: 'John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().length < 2) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Age & Gender Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                controller: _ageController,
                                label: 'Age',
                                hintText: '32',
                                prefixIcon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || int.tryParse(val.trim()) == null) {
                                    return 'Valid age';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gender',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedGender,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    dropdownColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                                    ),
                                    items: _genderOptions
                                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedGender = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 2: Clinical Details
                        _buildSectionHeader('2. Emergency Medical Details', isDark),

                        // Blood Group Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blood Group',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedBloodGroup,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.bloodtype_outlined, color: AppColors.esi1Critical),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              dropdownColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                              ),
                              items: _bloodGroups
                                  .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedBloodGroup = val);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Pre-Existing Medical Conditions (Optional)
                        Text(
                          'Pre-Existing Medical Conditions (Optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _medicalConditionsOptions.map((condition) {
                            final isSelected = _selectedConditions.contains(condition);
                            return FilterChip(
                              label: Text(condition),
                              selected: isSelected,
                              selectedColor: (isDark ? AppColors.primaryAccent : AppColors.primary500).withValues(alpha: 0.2),
                              checkmarkColor: isDark ? AppColors.primaryAccent : AppColors.primary500,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? AppColors.primaryAccent : AppColors.primary500)
                                    : (isDark ? AppColors.neutral400 : AppColors.neutral700),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    if (condition == 'None') {
                                      _selectedConditions.clear();
                                      _selectedConditions.add('None');
                                    } else {
                                      _selectedConditions.remove('None');
                                      _selectedConditions.add(condition);
                                    }
                                  } else {
                                    _selectedConditions.remove(condition);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Section 3: Emergency ICE Contact
                        _buildSectionHeader('3. Emergency ICE Contact', isDark),

                        // ICE Contact Name
                        CustomTextField(
                          controller: _emergencyNameController,
                          label: 'ICE Contact Name',
                          hintText: 'Spouse / Parent / Sibling Name',
                          prefixIcon: Icons.contact_phone_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Emergency contact name required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ICE Emergency Contact Phone
                        CustomTextField(
                          controller: _emergencyPhoneController,
                          label: 'Emergency Contact Phone',
                          hintText: '+1 (555) 019-2834',
                          prefixIcon: Icons.phone_callback_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.trim().length < 8) {
                              return 'Valid phone number required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Section 4: Account Credentials
                        _buildSectionHeader('4. Account & Security', isDark),

                        // Patient Phone Number
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Your Phone Number',
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.trim().length < 8) {
                              return 'Valid phone number required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email Address
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: 'john.doe@mediverse.health',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                              return 'Valid email address required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        PasswordField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: '••••••••',
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        PasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: '••••••••',
                          textInputAction: TextInputAction.done,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Terms & Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                checkColor: isDark ? AppColors.neutral900 : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() => _acceptedTerms = val ?? false);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark ? AppColors.neutral400 : AppColors.neutral700,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: GoogleFonts.poppins(
                                        color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'HIPAA Emergency Data Sharing Policy',
                                      style: GoogleFonts.poppins(
                                        color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Submit Primary Button
                        PrimaryButton(
                          text: 'Create Health Passport',
                          isLoading: _isLoading,
                          icon: Icons.badge_outlined,
                          onPressed: _handleRegister,
                        ),

                        const SizedBox(height: 16),

                        // Login Footer Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have a MediVerse profile? ',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go(RouteNames.login),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.primaryAccent : AppColors.primary500,
        ),
      ),
    );
  }
}
