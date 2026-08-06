import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../buttons/primary_button.dart';

/// Reusable Enterprise Material 3 Error Widget
class ErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final IconData icon;
  final bool isFullScreen;

  const ErrorWidget({
    super.key,
    this.title = 'Connection Issue',
    this.message = 'Unable to connect to MediVerse servers. Please check your internet connection and try again.',
    this.onRetry,
    this.retryButtonText = 'Retry Request',
    this.icon = Icons.error_outline_rounded,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.esi1Critical.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.esi1Critical.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.esi1Critical,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.neutral100 : AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                height: 1.45,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: PrimaryButton(
                  text: retryButtonText,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
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

/// Alias for MedicalErrorWidget
typedef MedicalErrorWidget = ErrorWidget;
