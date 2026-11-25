/// ai_badge.dart - AI Summary Tag Indicator

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AiBadge extends StatelessWidget {
  final bool compact;

  const AiBadge({Key? key, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF581C87)]
              : [const Color(0xFFEFF6FF), const Color(0xFFF3E8FF)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B82F6).withOpacity(0.4)
              : const Color(0xFF93C5FD),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: compact ? 12 : 14,
            color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
          ),
          const SizedBox(width: 5),
          Text(
            compact ? 'AI SUMMARY' : 'AI SUMMARY • 2 SENTENCES',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlueHover,
            ),
          ),
        ],
      ),
    );
  }
}
