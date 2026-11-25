/// search_bar_widget.dart - Clean Search Bar for TechBrief

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search articles by title, source, topic...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextNavy,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
