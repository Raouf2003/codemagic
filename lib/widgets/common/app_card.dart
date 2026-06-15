import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final Widget? header;
  final VoidCallback? onTap;
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.accentColor,
    this.header,
    this.onTap,
    this.width,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      width: widget.width,
      margin: widget.margin,
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.accentColor != null)
            Container(height: 3, color: widget.accentColor),
          if (widget.header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: widget.header,
            ),
          if (widget.header != null && widget.header != const SizedBox.shrink())
            const GapH(8),
          Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => widget.onTap != null ? setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && widget.onTap != null ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: widget.onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: card,
                  ),
                )
              : card,
        ),
      ),
    );
  }
}
