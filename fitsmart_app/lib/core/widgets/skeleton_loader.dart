import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_extensions.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Shimmer.fromColors(
      baseColor: c.bgTertiary,
      highlightColor: c.bgElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: c.bgTertiary,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Shimmer.fromColors(
      baseColor: c.surfaceCard,
      highlightColor: c.bgElevated,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: c.surfaceCardBorder),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        children: [
          const SkeletonCard(height: 220),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonCard(height: 100),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: const [
              Expanded(child: SkeletonCard(height: 80)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonCard(height: 80)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonCard(height: 150),
        ],
      ),
    );
  }
}
