import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// Premium Enterprise Splash Screen for MediVerse
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Continuous subtle pulsing ring animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Navigate to Login after exactly 3 seconds
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(RouteNames.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Radial Glow Accents
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary400.withValues(alpha: isDark ? 0.15 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.15,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Centered Content Stack
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Logo Container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Pulsing Glow Circle
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary500.withValues(alpha: 0.15),
                            ),
                          ),
                        ),

                        // Core Shield Icon Container
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary500, AppColors.primary600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary500.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),

                        // Cyber Teal AI Activity Pulse Dot
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryAccent,
                              border: Border.all(
                                color: isDark ? AppColors.darkCanvas : Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.75, 0.75),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 32),

                    // MediVerse Brand Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Medi',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.neutral900,
                          ),
                        ),
                        Text(
                          'Verse',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 300.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 8),

                    // Tagline: "AI Assisted Emergency Healthcare"
                    Text(
                      'AI Assisted Emergency Healthcare',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 500.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const Spacer(),

                    // Linear Loading Bar
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.neutral200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.primaryAccent : AppColors.primary500,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 500.ms),

                    const SizedBox(height: 16),

                    // Security & Compliance Caption
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HIPAA Compliant • Encrypted Health Protocol',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 500.ms),

                    const SizedBox(height: 24),
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
