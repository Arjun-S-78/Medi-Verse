import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Enterprise Material 3 Secondary (Outlined / Tonal) Button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.trailingIcon,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.height = 52.0,
    this.width,
    this.borderRadius = 14.0,
    this.fontSize = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.neutral200;
    final defaultFg = isDark ? AppColors.neutral100 : AppColors.primary500;
    final defaultBg = isDark ? AppColors.darkSurfaceCard : Colors.transparent;

    final border = borderColor ?? defaultBorder;
    final fg = textColor ?? defaultFg;
    final bg = backgroundColor ?? defaultBg;
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledForegroundColor: isDark ? AppColors.neutral600 : AppColors.neutral400,
          side: BorderSide(
            color: isDisabled
                ? (isDark ? AppColors.darkBorder : AppColors.neutral200)
                : border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: effectiveOnPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: fg,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20, color: fg),
                  ],
                ],
              ),
      ),
    );
  }
}
