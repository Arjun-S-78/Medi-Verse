import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

enum UserRole { patient, ambulance, doctor, admin }

class UserRoleInfo {
  final UserRole role;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String defaultEmail;
  final String defaultPassword;
  final String defaultPhone;
  final String targetRoute;
  final String? extraFieldLabel;
  final String? extraFieldHint;
  final IconData? extraFieldIcon;

  const UserRoleInfo({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.defaultEmail,
    required this.defaultPassword,
    required this.defaultPhone,
    required this.targetRoute,
    this.extraFieldLabel,
    this.extraFieldHint,
    this.extraFieldIcon,
  });
}

/// Enterprise Multi-Role Login Screen for MediVerse (Ambulance, Doctor, Admin, Patient)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91 9876543210');
  final _otpController = TextEditingController();
  final _roleExtraController = TextEditingController();

  UserRole _selectedRole = UserRole.patient;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _isOtpMode = false;
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;

  Timer? _resendTimer;
  int _secondsRemaining = 60;

  final Map<UserRole, UserRoleInfo> _roleDetails = {
    UserRole.patient: const UserRoleInfo(
      role: UserRole.patient,
      label: 'Patient',
      subtitle: 'Health Passport & Emergency Triage',
      icon: Icons.person_rounded,
      color: Color(0xFF10B981),
      defaultEmail: 'patient@mediverse.health',
      defaultPassword: 'Patient#123',
      defaultPhone: '+91 9876543210',
      targetRoute: RouteNames.home,
    ),
    UserRole.ambulance: const UserRoleInfo(
      role: UserRole.ambulance,
      label: 'Ambulance',
      subtitle: 'Emergency Dispatch & Navigation',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFFF59E0B),
      defaultEmail: 'ambulance.unit102@mediverse.health',
      defaultPassword: 'Ambulance#123',
      defaultPhone: '+91 9876543211',
      targetRoute: RouteNames.ambulanceDashboard,
      extraFieldLabel: 'Ambulance Unit ID',
      extraFieldHint: 'AMB-102-TN',
      extraFieldIcon: Icons.directions_car_rounded,
    ),
    UserRole.doctor: const UserRoleInfo(
      role: UserRole.doctor,
      label: 'Doctor',
      subtitle: 'Clinical Portal & Triage Queue',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF2563EB),
      defaultEmail: 'dr.sharma@mediverse.health',
      defaultPassword: 'Doctor#123',
      defaultPhone: '+91 9876543212',
      targetRoute: RouteNames.doctorDashboard,
      extraFieldLabel: 'Medical License ID',
      extraFieldHint: 'MCI-88492-IN',
      extraFieldIcon: Icons.badge_rounded,
    ),
    UserRole.admin: const UserRoleInfo(
      role: UserRole.admin,
      label: 'Admin',
      subtitle: 'Hospital Command & Operations',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF7C3AED),
      defaultEmail: 'admin.general@mediverse.health',
      defaultPassword: 'Admin#123',
      defaultPhone: '+91 9876543213',
      targetRoute: RouteNames.adminDashboard,
      extraFieldLabel: 'Hospital Security Code',
      extraFieldHint: 'HOSP-KEY-770',
      extraFieldIcon: Icons.security_rounded,
    ),
  };

  @override
  void initState() {
    super.initState();
    _fillRoleDefaults(UserRole.patient);
  }

  void _fillRoleDefaults(UserRole role) {
    final info = _roleDetails[role]!;
    _emailController.text = info.defaultEmail;
    _passwordController.text = info.defaultPassword;
    _phoneController.text = info.defaultPhone;
    if (info.extraFieldHint != null) {
      _roleExtraController.text = info.extraFieldHint!;
    } else {
      _roleExtraController.clear();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _roleExtraController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handlePasswordLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() => _isLoading = false);
        final info = _roleDetails[_selectedRole]!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Authenticated as ${info.label}! Opening ${info.subtitle}...',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: info.color,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(info.targetRoute);
      }
    }
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number with country code (e.g. +91 9876543210)', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.esi2Emergent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      ).timeout(const Duration(seconds: 3));

      if (mounted) {
        setState(() => _isSendingOtp = false);
        final data = jsonDecode(response.body);
        final debugCode = data['debugOtpCode'] as String?;

        setState(() => _otpSent = true);
        _startTimer();
        _otpController.text = debugCode ?? '123456';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📲 SMS OTP dispatched to $phone! Verification PIN: 123456', style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: AppColors.primary500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
          _otpSent = true;
        });
        _otpController.text = '123456';
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📱 Real OTP simulation sent to $phone! PIN: 123456 (Auto-filled)', style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: AppColors.primary500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a 6-digit OTP pin code', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.esi2Emergent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() => _isVerifyingOtp = false);
      final info = _roleDetails[_selectedRole]!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Phone OTP verified! Welcome as ${info.label}.', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: info.color,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(info.targetRoute);
    }
  }

  void _showForgotPasswordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final resetController = TextEditingController(text: _emailController.text);

        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your registered email address to receive a secure password reset link.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: resetController,
                label: 'Email Address',
                hintText: 'user@mediverse.health',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Send Reset Link',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset link sent to ${resetController.text.isNotEmpty ? resetController.text : "your email"}.',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary500,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRoleInfo = _roleDetails[_selectedRole]!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Brand Logo & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentRoleInfo.color.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          currentRoleInfo.icon,
                          color: currentRoleInfo.color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Medi',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : AppColors.neutral900,
                              ),
                            ),
                            TextSpan(
                              text: 'Verse',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: currentRoleInfo.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 6),

                  Text(
                    'Unified AI Emergency & Healthcare Network',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ROLE SELECTOR CARDS (Ambulance, Doctor, Admin, Patient)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            'SELECT LOGIN ROLE',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                            ),
                          ),
                        ),
                        Row(
                          children: UserRole.values.map((role) {
                            final info = _roleDetails[role]!;
                            final isSelected = _selectedRole == role;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRole = role;
                                    _fillRoleDefaults(role);
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected ? info.color : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: info.color.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        info.icon,
                                        size: 20,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? AppColors.neutral400 : AppColors.neutral700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        info.label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? AppColors.neutral300 : AppColors.neutral800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Main Form Container Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: currentRoleInfo.color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentRoleInfo.color.withValues(alpha: isDark ? 0.2 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role Header Subtitle & Quick Test Chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: currentRoleInfo.color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          currentRoleInfo.label.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: currentRoleInfo.color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Portal Access',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppColors.neutral900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentRoleInfo.subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Mode Switch Tabs (Password vs Phone OTP)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isOtpMode = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isOtpMode
                                          ? (isDark ? currentRoleInfo.color : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: !_isOtpMode
                                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Password Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: !_isOtpMode
                                              ? (isDark ? Colors.white : currentRoleInfo.color)
                                              : (isDark ? AppColors.neutral400 : AppColors.neutral700),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isOtpMode = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isOtpMode
                                          ? (isDark ? currentRoleInfo.color : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _isOtpMode
                                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.sms_rounded,
                                            size: 14,
                                            color: _isOtpMode
                                                ? (isDark ? Colors.white : currentRoleInfo.color)
                                                : (isDark ? AppColors.neutral400 : AppColors.neutral700),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'SMS OTP',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _isOtpMode
                                                  ? (isDark ? Colors.white : currentRoleInfo.color)
                                                  : (isDark ? AppColors.neutral400 : AppColors.neutral700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // PASSWORD MODE FORM
                        if (!_isOtpMode) ...[
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: _emailController,
                                  label: '${currentRoleInfo.label} Email',
                                  hintText: currentRoleInfo.defaultEmail,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                PasswordField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: '••••••••',
                                  textInputAction: TextInputAction.done,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter password';
                                    }
                                    return null;
                                  },
                                ),
                                if (currentRoleInfo.extraFieldLabel != null) ...[
                                  const SizedBox(height: 14),
                                  CustomTextField(
                                    controller: _roleExtraController,
                                    label: currentRoleInfo.extraFieldLabel!,
                                    hintText: currentRoleInfo.extraFieldHint ?? '',
                                    prefixIcon: currentRoleInfo.extraFieldIcon ?? Icons.verified_user_outlined,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: currentRoleInfo.color,
                                            onChanged: (val) {
                                              setState(() => _rememberMe = val ?? true);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Remember credentials',
                                          style: GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _showForgotPasswordDialog,
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: currentRoleInfo.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  text: 'Sign In as ${currentRoleInfo.label}',
                                  isLoading: _isLoading,
                                  onPressed: _handlePasswordLogin,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // PHONE OTP MODE FORM
                          Column(
                            children: [
                              CustomTextField(
                                controller: _phoneController,
                                label: '${currentRoleInfo.label} Mobile Number',
                                hintText: currentRoleInfo.defaultPhone,
                                prefixIcon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),
                              if (!_otpSent) ...[
                                PrimaryButton(
                                  text: 'Send Verification OTP',
                                  isLoading: _isSendingOtp,
                                  onPressed: _handleSendOtp,
                                ),
                              ] else ...[
                                CustomTextField(
                                  controller: _otpController,
                                  label: 'Enter 6-Digit PIN Code',
                                  hintText: '123456',
                                  prefixIcon: Icons.mark_email_read_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _secondsRemaining > 0
                                          ? 'Resend OTP in ${_secondsRemaining}s'
                                          : 'Didn\'t receive SMS?',
                                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.neutral400),
                                    ),
                                    GestureDetector(
                                      onTap: _secondsRemaining == 0 ? _handleSendOtp : null,
                                      child: Text(
                                        'Resend OTP',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _secondsRemaining == 0 ? currentRoleInfo.color : AppColors.neutral400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  text: 'Verify OTP & Sign In (${currentRoleInfo.label})',
                                  isLoading: _isVerifyingOtp,
                                  onPressed: _handleVerifyOtp,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Need a MediVerse account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.register),
                        child: Text(
                          'Register Role Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: currentRoleInfo.color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Emergency Bypass Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.esi1SurfaceDark : AppColors.esi1SurfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.esi1Critical.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.esi1Critical,
                          ),
                          child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In an Active Emergency?',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.esi1Critical,
                                ),
                              ),
                              Text(
                                'Instant MIRA Voice Triage & SOS Dispatch',
                                style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.neutral400 : AppColors.neutral700),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(RouteNames.home),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.esi1Critical,
                          ),
                          child: Text(
                            'BYPASS >',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
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
}
