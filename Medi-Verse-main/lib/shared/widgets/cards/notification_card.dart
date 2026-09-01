import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable Emergency Notification Card Component
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.icon = Icons.notifications_active_outlined,
    this.iconColor = AppColors.primary500,
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread
            ? iconColor.withValues(alpha: isDark ? 0.12 : 0.05)
            : (isDark ? AppColors.darkSurfaceCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? iconColor.withValues(alpha: 0.4) : (isDark ? AppColors.darkBorder : AppColors.neutral200),
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral600, height: 1.3),
          ),
        ),
      ),
    );
  }
}
