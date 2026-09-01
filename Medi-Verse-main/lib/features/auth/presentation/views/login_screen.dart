import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

/// Enterprise-Grade Login Screen for MediVerse
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(RouteNames.home);
      }
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
                hintText: 'patient@mediverse.health',
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
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
                          color: AppColors.primary500.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: isDark ? AppColors.primaryAccent : AppColors.primary500,
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
                                color: isDark ? AppColors.primaryAccent : AppColors.primary400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 8),

                  Text(
                    'AI Assisted Emergency Healthcare',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // Main Form Card Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : AppColors.neutral900.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to access your Health Passport & Triage',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email Input Field
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'patient@mediverse.health',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password Input Field
                          PasswordField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: '••••••••',
                            textInputAction: TextInputAction.done,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Remember Me & Forgot Password Options
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
                                      activeColor: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                      checkColor: isDark ? AppColors.neutral900 : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? true;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Primary Sign In Button
                          PrimaryButton(
                            text: 'Sign In',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),

                          const SizedBox(height: 20),

                          // Divider Or
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Sign In Button (UI Only)
                          SocialAuthButton(
                            text: 'Continue with Google',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Google Sign In initialized...',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            iconWidget: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.g_mobiledata_rounded,
                                size: 28,
                                color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 20),

                  // Register Now Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have a medical profile? ",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.register),
                        child: Text(
                          'Register Now',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms),

                  const SizedBox(height: 20),

                  // Instant Emergency Triage Bypass Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.esi1SurfaceDark : AppColors.esi1SurfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.esi1Critical.withValues(alpha: 0.4),
                        width: 1,
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
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In a Medical Emergency?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.esi1Critical,
                                ),
                              ),
                              Text(
                                'Bypass sign-in for instant MIRA Triage',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDark ? AppColors.neutral400 : AppColors.neutral700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(RouteNames.home);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.esi1Critical,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: Text(
                            'BYPASS >',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
