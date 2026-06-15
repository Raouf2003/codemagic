import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum AvatarSize { sm, md, lg, xl }

class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final AvatarSize size;
  final bool showStatus;
  final bool statusOnline;

  const AvatarWidget({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = AvatarSize.md,
    this.showStatus = false,
    this.statusOnline = true,
  });

  double get _dimension {
    switch (size) {
      case AvatarSize.sm: return 32;
      case AvatarSize.md: return 40;
      case AvatarSize.lg: return 56;
      case AvatarSize.xl: return 72;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.sm: return 12;
      case AvatarSize.md: return 16;
      case AvatarSize.lg: return 22;
      case AvatarSize.xl: return 28;
    }
  }

  Color _bgColor(String name) {
    final hash = name.hashCode;
    final colors = [
      AppColors.indigo,
      AppColors.emerald,
      AppColors.blue,
      AppColors.amber,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    return colors[hash.abs() % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(name);
    final dim = _dimension;

    final avatar = CircleAvatar(
      radius: dim / 2,
      backgroundColor: bg.withValues(alpha: 0.15),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(_initials(name),
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: bg,
              ),
            )
          : null,
    );

    if (!showStatus) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusOnline ? AppColors.emerald : AppColors.textMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardWhite, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
