import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../feedback/status_badge.dart';

/// Reusable Hospital List Tile
class HospitalTile extends StatelessWidget {
  final String name;
  final String distance;
  final String icuBeds;
  final String traumaLevel;
  final Color statusColor;
  final VoidCallback? onTap;

  const HospitalTile({
    super.key,
    required this.name,
    required this.distance,
    required this.icuBeds,
    required this.traumaLevel,
    this.statusColor = AppColors.esi4LessUrgent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.neutral200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor.withValues(alpha: 0.12),
          ),
          child: Icon(Icons.local_hospital_outlined, color: statusColor, size: 24),
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$traumaLevel • $distance',
          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        trailing: StatusBadge(
          label: icuBeds,
          color: statusColor,
        ),
      ),
    );
  }
}
