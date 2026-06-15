import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum BadgeSize { small, medium }

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final BadgeSize size;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
    this.size = BadgeSize.medium,
    this.showDot = true,
  });

  // Semantic constructors
  factory StatusBadge.success(String label, {BadgeSize size = BadgeSize.medium}) =>
      StatusBadge(label: label, color: AppColors.emerald, bgColor: AppColors.emeraldLight, size: size);

  factory StatusBadge.warning(String label, {BadgeSize size = BadgeSize.medium}) =>
      StatusBadge(label: label, color: AppColors.amber, bgColor: AppColors.amberLight, size: size);

  factory StatusBadge.error(String label, {BadgeSize size = BadgeSize.medium}) =>
      StatusBadge(label: label, color: AppColors.red, bgColor: AppColors.redLight, size: size);

  factory StatusBadge.info(String label, {BadgeSize size = BadgeSize.medium}) =>
      StatusBadge(label: label, color: AppColors.blue, bgColor: AppColors.blueLight, size: size);

  factory StatusBadge.neutral(String label, {BadgeSize size = BadgeSize.medium}) =>
      StatusBadge(label: label, color: AppColors.textMuted, bgColor: AppColors.divider, size: size);

  @override
  Widget build(BuildContext context) {
    final padH = size == BadgeSize.small ? 8.0 : 10.0;
    final padV = size == BadgeSize.small ? 3.0 : 5.0;
    final fontSize = size == BadgeSize.small ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
