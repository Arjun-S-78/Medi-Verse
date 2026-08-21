import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../buttons/primary_button.dart';

/// Reusable Material 3 Confirmation & Emergency Dialog
class MedicalDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onConfirm;

  const MedicalDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = AppColors.esi1Critical,
    required this.onConfirm,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String description,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.warning_amber_rounded,
    Color iconColor = AppColors.esi1Critical,
    required VoidCallback onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => MedicalDialog(
        title: title,
        description: description,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral600, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: confirmText,
                    backgroundColor: iconColor,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
