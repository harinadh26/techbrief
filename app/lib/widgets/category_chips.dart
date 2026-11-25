/// category_chips.dart - Horizontal Category Filter Chips

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Artificial Intelligence':
        return Icons.psychology_outlined;
      case 'Startups':
        return Icons.rocket_launch_outlined;
      case 'Cybersecurity':
        return Icons.security_outlined;
      case 'Gadgets':
        return Icons.devices_outlined;
      case 'Software':
        return Icons.code_outlined;
      case 'Technology':
        return Icons.computer_outlined;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.toLowerCase() == selectedCategory.toLowerCase();

          return InkWell(
            onTap: () => onCategorySelected(cat),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : (isDark ? AppColors.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(cat),
                    size: 15,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextNavy),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
