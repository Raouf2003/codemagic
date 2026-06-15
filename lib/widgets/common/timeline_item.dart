import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String? timestamp;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: dark ? AppColors.darkBorder : AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const GapW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GapH(4),
                Text(title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? AppColors.darkText : AppColors.textDark,
                  ),
                ),
                const GapH(2),
                Text(subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                if (timestamp != null) ...[
                  const GapH(2),
                  Text(timestamp!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
                if (!isLast) const GapH(16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
