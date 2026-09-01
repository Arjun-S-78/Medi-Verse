import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable Enterprise Material 3 Loading Widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool isFullScreen;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 54.0,
    this.color,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? (isDark ? AppColors.primaryAccent : AppColors.primary500);

    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulse animation ring
              Container(
                width: size * 1.4,
                height: size * 1.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.25, 1.25), duration: 900.ms)
                  .fade(begin: 0.3, end: 0.7),

              // Inner Icon Container
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.neutral400 : AppColors.neutral700,
              ),
            ),
          ],
        ],
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
        body: content,
      );
    }

    return content;
  }
}
