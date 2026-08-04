import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const CustomShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppColors.cardBackground.withValues(alpha: 0.5),
        highlightColor: AppColors.primaryBlue.withValues(alpha: 0.1),
        period: const Duration(milliseconds: 1500),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  static Widget list({
    int count = 5,
    double height = 100,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ListView.builder(
      itemCount: count,
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => CustomShimmer(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  static Widget grid({
    int count = 6,
    double height = 150,
    int crossAxisCount = 2,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return GridView.builder(
      itemCount: count,
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: height,
      ),
      itemBuilder: (context, index) => CustomShimmer(
        width: double.infinity,
        height: height,
      ),
    );
  }
}
