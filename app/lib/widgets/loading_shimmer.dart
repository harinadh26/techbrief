/// loading_shimmer.dart - Loading Skeleton Cards for TechBrief

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingShimmerWidget extends StatefulWidget {
  const LoadingShimmerWidget({Key? key}) : super(key: key);

  @override
  State<LoadingShimmerWidget> createState() => _LoadingShimmerWidgetState();
}

class _LoadingShimmerWidgetState extends State<LoadingShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final opacity = _animation.value;

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 18,
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(opacity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 90,
                        height: 14,
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(opacity * 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(opacity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 18,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(opacity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(opacity * 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
