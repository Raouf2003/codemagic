import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import 'shift_settings_screen.dart';
import 'geofence_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GapH(8),
          Text(l10n.settings, style: AppTypography.h3.copyWith(color: AppColors.textDark)),
          const GapH(4),
          Text(l10n.manageShiftGeofence,
            style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          const GapH(20),
          _SettingsCard(
            icon: Icons.schedule,
            color: AppColors.amber,
            title: l10n.shiftConfig,
            subtitle: l10n.setMorningEveningShift,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftSettingsScreen())),
          ),
          const GapH(12),
          _SettingsCard(
            icon: Icons.location_on,
            color: AppColors.indigo,
            title: l10n.geofenceConfig,
            subtitle: l10n.setCompanyLocationRadius,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeofenceSettingsScreen())),
          ),
          const GapH(12),
          Consumer<ThemeProvider>(
            builder: (_, tp, __) => _SettingsCard(
              icon: tp.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.amber,
              title: l10n.toggleTheme,
              subtitle: tp.isDarkMode ? l10n.switchToLight : l10n.switchToDark,
              onTap: tp.toggleTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkCard : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: dark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const GapW(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dark ? AppColors.darkText : AppColors.textDark,
                    )),
                    const GapH(4),
                    Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
