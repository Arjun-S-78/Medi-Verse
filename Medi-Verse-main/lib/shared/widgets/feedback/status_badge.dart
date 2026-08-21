import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

enum StatusBadgeType {
  critical,
  emergent,
  urgent,
  lessUrgent,
  nonUrgent,
  active,
  completed,
  pending,
  custom,
}

/// Enterprise Material 3 Medical Status & Manchester Triage Badge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool showDot;
  final StatusBadgeType type;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.showDot = true,
    this.type = StatusBadgeType.custom,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 11.0,
  });

  factory StatusBadge.critical({Key? key, String label = 'ESI 1: Resuscitation'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi1Critical,
      icon: Icons.warning_amber_rounded,
      type: StatusBadgeType.critical,
    );
  }

  factory StatusBadge.emergent({Key? key, String label = 'ESI 2: Emergent'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi2Emergent,
      icon: Icons.error_outline_rounded,
      type: StatusBadgeType.emergent,
    );
  }

  factory StatusBadge.urgent({Key? key, String label = 'ESI 3: Urgent'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi3Urgent,
      icon: Icons.info_outline_rounded,
      type: StatusBadgeType.urgent,
    );
  }

  factory StatusBadge.lessUrgent({Key? key, String label = 'ESI 4: Less Urgent'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi4LessUrgent,
      icon: Icons.check_circle_outline_rounded,
      type: StatusBadgeType.lessUrgent,
    );
  }

  factory StatusBadge.nonUrgent({Key? key, String label = 'ESI 5: Non-Urgent'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi5NonUrgent,
      icon: Icons.help_outline_rounded,
      type: StatusBadgeType.nonUrgent,
    );
  }

  factory StatusBadge.active({Key? key, String label = 'Active'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.primary500,
      icon: Icons.radio_button_checked_rounded,
      type: StatusBadgeType.active,
    );
  }

  factory StatusBadge.completed({Key? key, String label = 'Completed'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi4LessUrgent,
      icon: Icons.check_rounded,
      type: StatusBadgeType.completed,
    );
  }

  factory StatusBadge.pending({Key? key, String label = 'Pending'}) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.esi3Urgent,
      icon: Icons.access_time_rounded,
      type: StatusBadgeType.pending,
    );
  }

  Color _resolveColor() {
    if (color != null) return color!;
    switch (type) {
      case StatusBadgeType.critical:
        return AppColors.esi1Critical;
      case StatusBadgeType.emergent:
        return AppColors.esi2Emergent;
      case StatusBadgeType.urgent:
        return AppColors.esi3Urgent;
      case StatusBadgeType.lessUrgent:
        return AppColors.esi4LessUrgent;
      case StatusBadgeType.nonUrgent:
        return AppColors.esi5NonUrgent;
      case StatusBadgeType.active:
        return AppColors.primary500;
      case StatusBadgeType.completed:
        return AppColors.esi4LessUrgent;
      case StatusBadgeType.pending:
        return AppColors.esi3Urgent;
      case StatusBadgeType.custom:
        return AppColors.primary500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _resolveColor();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: effectiveColor),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: effectiveColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
