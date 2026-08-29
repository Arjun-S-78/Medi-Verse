import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Enterprise Skeleton Shimmer Placeholder Loader
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shapeBorder;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = AppTokens.radiusSm,
    this.shapeBorder,
  });

  const SkeletonLoader.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = AppTokens.radiusPill,
        shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurfaceCard : AppColors.neutral200;
    final highlightColor = isDark ? AppColors.darkBorder : Colors.white;

    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        shape: shapeBorder ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
        color: baseColor,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .shimmer(
       duration: const Duration(milliseconds: 1200),
       color: highlightColor.withValues(alpha: 0.5),
     );
  }
}

/// Skeleton Loader Card for List / Grid Placeholders
class SkeletonCardLoader extends StatelessWidget {
  final double height;

  const SkeletonCardLoader({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.neutral200,
        ),
      ),
      child: const Row(
        children: [
          SkeletonLoader.circular(size: 48),
          SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoader(width: 140, height: 16),
                SizedBox(height: 8),
                SkeletonLoader(width: 200, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
