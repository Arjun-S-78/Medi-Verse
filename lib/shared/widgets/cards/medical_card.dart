import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../feedback/status_badge.dart';

/// Reusable Enterprise Material 3 Medical Card
class MedicalCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final String? badgeText;
  final Color? badgeColor;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? accentColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final double elevation;

  const MedicalCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.badgeText,
    this.badgeColor,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.accentColor,
    this.onTap,
    this.borderRadius = 20.0,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = AppColors.darkSurfaceCard;
    final defaultBorder = AppColors.darkBorder;

    final bg = backgroundColor ?? defaultBg;
    final border = borderColor ?? defaultBorder;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || icon != null || badgeText != null || trailing != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary500).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? (isDark ? AppColors.primaryAccent : AppColors.primary500),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                StatusBadge(
                  label: badgeText!,
                  color: badgeColor ?? AppColors.primary500,
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          if (child != null) const SizedBox(height: 12),
        ],
        if (child case final Widget body) body,
      ],
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: elevation * 4,
              offset: Offset(0, elevation),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accentColor != null)
                Container(
                  width: 5,
                  color: accentColor,
                ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Padding(
                    padding: padding,
                    child: cardContent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
