import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

void showSuccess(BuildContext context, String message) {
  _show(context, message, AppColors.emerald, Icons.check_circle);
}

void showError(BuildContext context, String message) {
  _show(context, message, AppColors.red, Icons.error_outline);
}

void showInfo(BuildContext context, String message) {
  _show(context, message, AppColors.amber, Icons.info_outline);
}

void _show(BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 3),
    ),
  );
}
