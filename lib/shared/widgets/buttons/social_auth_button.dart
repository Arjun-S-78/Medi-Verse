import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable Enterprise Social Auth Button (Google, Apple, SSO)
class SocialAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget iconWidget;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.neutral200,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.neutral100 : AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
