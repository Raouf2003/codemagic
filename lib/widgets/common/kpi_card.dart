import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class KpiCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;
  final String? trend;
  final bool trendUp;

  const KpiCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
    this.trend,
    this.trendUp = true,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          height: double.infinity,
          decoration: BoxDecoration(
            color: dark ? AppColors.darkCard : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(
                  alpha: dark ? (_hovered ? 0.35 : 0.2) : (_hovered ? 0.12 : 0.06),
                ),
                blurRadius: _hovered ? 20 : 12,
                offset: Offset(0, _hovered ? 4 : 2),
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.iconBgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(widget.value,
            style: AppTypography.h2.copyWith(
              color: dark ? AppColors.darkText : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.label,
            style: AppTypography.caption.copyWith(
              color: dark ? AppColors.darkMuted : AppColors.textMuted,
            ),
          ),
          if (widget.trend != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  widget.trendUp ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: widget.trendUp ? AppColors.emerald : AppColors.red,
                ),
                const SizedBox(width: 4),
                Text(widget.trend!,
                  style: AppTypography.caption.copyWith(
                    color: widget.trendUp ? AppColors.emerald : AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
    ),
    );
  }
}
