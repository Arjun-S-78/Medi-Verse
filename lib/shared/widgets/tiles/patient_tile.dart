import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../avatars/medical_avatar.dart';
import '../feedback/status_badge.dart';

/// Reusable Patient List Tile
class PatientTile extends StatelessWidget {
  final String name;
  final String ageAndGender;
  final String bloodGroup;
  final String? subtitle;
  final VoidCallback? onTap;

  const PatientTile({
    super.key,
    required this.name,
    required this.ageAndGender,
    required this.bloodGroup,
    this.subtitle,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: MedicalAvatar(name: name, radius: 22),
        title: Text(
          name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle ?? ageAndGender,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        trailing: StatusBadge(
          label: bloodGroup,
          color: AppColors.esi1Critical,
          icon: Icons.bloodtype_outlined,
        ),
      ),
    );
  }
}
