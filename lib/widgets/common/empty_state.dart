import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.indigo.withValues(alpha: 0.1),
                    AppColors.indigoLight.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(icon, size: 36, color: AppColors.indigoLight.withValues(alpha: 0.6)),
            ),
            const GapH(20),
            Text(title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color: dark ? AppColors.darkText : AppColors.textDark,
              ),
            ),
            const GapH(8),
            Text(subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: dark ? AppColors.darkMuted : AppColors.textMuted,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const GapH(24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
