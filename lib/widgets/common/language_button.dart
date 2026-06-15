import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final cs = Theme.of(context).colorScheme;
    final current = localeProvider.locale.languageCode;

    return PopupMenuButton<String>(
      icon: Icon(Icons.translate_rounded,
          color: cs.onSurfaceVariant, size: 22),
      tooltip: 'Language',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (code) {
        localeProvider.setLocale(Locale(code));
      },
      itemBuilder: (ctx) => [
        _langItem(ctx, 'en', 'English', current),
        _langItem(ctx, 'fr', 'Français', current),
        _langItem(ctx, 'ar', 'العربية', current),
      ],
    );
  }

  PopupMenuItem<String> _langItem(
      BuildContext ctx, String code, String label, String current) {
    return PopupMenuItem(
      value: code,
      child: Row(
        children: [
          Icon(
            code == current
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 18,
            color: code == current
                ? Theme.of(ctx).colorScheme.primary
                : null,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontWeight: code == current
                      ? FontWeight.w600
                      : FontWeight.normal)),
        ],
      ),
    );
  }
}
