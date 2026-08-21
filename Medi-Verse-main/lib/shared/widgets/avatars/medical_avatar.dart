import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable Medical User & Doctor Avatar
class MedicalAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final bool showOnlineStatus;

  const MedicalAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24.0,
    this.showOnlineStatus = false,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'MV';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary500.withValues(alpha: 0.15),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  _initials,
                  style: TextStyle(
                    fontSize: radius * 0.75,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                  ),
                )
              : null,
        ),
        if (showOnlineStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.esi4LessUrgent,
                border: Border.all(
                  color: isDark ? AppColors.darkCanvas : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
