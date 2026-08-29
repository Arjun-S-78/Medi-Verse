import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../avatars/medical_avatar.dart';

/// Reusable Doctor Profile List Tile
class DoctorTile extends StatelessWidget {
  final String name;
  final String specialty;
  final String hospitalName;
  final double rating;
  final VoidCallback? onCallPressed;

  const DoctorTile({
    super.key,
    required this.name,
    required this.specialty,
    required this.hospitalName,
    this.rating = 4.9,
    this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Row(
        children: [
          MedicalAvatar(name: name, radius: 24, showOnlineStatus: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '$specialty • $hospitalName',
                  style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.phone_outlined, color: AppColors.primary500, size: 20),
            onPressed: onCallPressed,
          ),
        ],
      ),
    );
  }
}
