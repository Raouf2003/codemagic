import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/report_photo.dart';
import '../../widgets/skeletons/skeleton_widget.dart';
import '../../l10n/l10n.dart';

// ─────────────────────────────────────────────
//  Shared helpers (no duplication)
// ─────────────────────────────────────────────
abstract class _ReportMeta {
  static const colors = <String, Color>{
    'issue': Color(0xFFEF4444),
    'inventory': Color(0xFF3B82F6),
    'feedback': Color(0xFF10B981),
  };

  static const icons = <String, IconData>{
    'issue': Icons.report_problem_rounded,
    'inventory': Icons.inventory_2_rounded,
    'feedback': Icons.feedback_rounded,
  };

  static Color color(String type) => colors[type] ?? const Color(0xFF94A3B8);
  static IconData icon(String type) => icons[type] ?? Icons.help_outline_rounded;

  static String label(String type, AppLocalizations l10n) {
    switch (type) {
      case 'issue':
        return l10n.issue;
      case 'inventory':
        return l10n.inventory;
      case 'feedback':
        return l10n.feedback;
      default:
        return type;
    }
  }
}

// ─────────────────────────────────────────────
//  List Screen
// ─────────────────────────────────────────────
class EmployeeReportsScreen extends StatefulWidget {
  const EmployeeReportsScreen({super.key});

  @override
  State<EmployeeReportsScreen> createState() => _EmployeeReportsScreenState();
}

class _EmployeeReportsScreenState extends State<EmployeeReportsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedType;

  int _page = 1;
  int _total = 0;
  int _totalPages = 0;
  static const int _limit = 20;

  // For staggered list animation
  AnimationController? _listAnimCtrl;

  List<Map<String, dynamic>> get _filtered {
    var result = _reports;
    if (_selectedType != null) {
      result = result.where((r) => r['type'] == _selectedType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) {
        final emp = r['employeeId'] ?? {};
        final name = (emp['fullName'] ?? '').toString().toLowerCase();
        final num = (emp['employeeNumber'] ?? '').toString();
        final desc = (r['description'] ?? '').toString().toLowerCase();
        return name.contains(q) || num.contains(q) || desc.contains(q);
      }).toList();
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _listAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadReports();
  }

  @override
  void dispose() {
    _listAnimCtrl?.dispose();
    super.dispose();
  }

  Future<void> _loadReports({int? page}) async {
    setState(() => _isLoading = true);
    try {
      _page = page ?? _page;
      final response = await _api.get('/employee-reports?page=$_page&limit=$_limit');
      final list = (response['reports'] as List?) ?? [];
      final pagination = response['pagination'] as Map? ?? {};
      if (!mounted) return;
      setState(() {
        _reports = list.map((r) => Map<String, dynamic>.from(r)).toList();
        _total = pagination['total'] as int? ?? 0;
        _totalPages = pagination['totalPages'] as int? ?? 0;
        _isLoading = false;
      });
      _listAnimCtrl?.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        _SearchBar(
          query: _searchQuery,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),
        _TypeFilterBar(
          selected: _selectedType,
          onSelect: (t) => setState(() => _selectedType = t),
        ),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
        Expanded(child: _buildBody(l10n, cs)),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n, ColorScheme cs) {
    if (_isLoading) return const SkeletonList(itemCount: 4, itemHeight: 120);

    if (_reports.isEmpty) {
      return EmptyState(
        icon: Icons.feedback_outlined,
        title: l10n.noReports,
        subtitle: l10n.noReportsSubtitle,
      );
    }

    final items = _filtered;
    if (items.isEmpty) return _NoMatch(l10n: l10n);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadReports(page: 1),
            color: cs.primary,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final cols = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 700
                        ? 2
                        : 1;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: cols > 1 ? 320 : 280,
                  ),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final ctrl = _listAnimCtrl;
                    if (ctrl == null) {
                      return _ReportCard(
                        report: items[i],
                        onTap: () => _openDetail(items[i]),
                      );
                    }
                    return _AnimatedCard(
                      index: i,
                      controller: ctrl,
                      child: _ReportCard(
                        report: items[i],
                        onTap: () => _openDetail(items[i]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        if (_total > _limit)
          _PaginationBar(
            page: _page,
            totalPages: _totalPages,
            total: _total,
            onPrevious: _page > 1 ? () => _loadReports(page: _page - 1) : null,
            onNext: _page < _totalPages ? () => _loadReports(page: _page + 1) : null,
          ),
      ],
    );
  }

  Future<void> _openDetail(Map<String, dynamic> r) async {
    final deleted = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ReportDetailScreen(report: r),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
    if (deleted == true) {
      _loadReports();
    }
  }
}

// ─────────────────────────────────────────────
//  Animated Card Wrapper (stagger)
// ─────────────────────────────────────────────
class _AnimatedCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedCard({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (_, __) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - curve.value)),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Search Bar
// ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchReports,
          hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel_rounded, size: 18, color: cs.onSurfaceVariant),
                  onPressed: onClear,
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Type Filter Bar
// ─────────────────────────────────────────────
class _TypeFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _TypeFilterBar({required this.selected, required this.onSelect});

  static const _types = <String?>[null, 'issue', 'inventory', 'feedback'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _types.map((type) {
            final isSelected = selected == type;
            final color = type != null ? _ReportMeta.color(type) : cs.primary;
            final icon = type != null ? _ReportMeta.icon(type) : Icons.grid_view_rounded;
            final label = type != null
                ? _ReportMeta.label(type, l10n)
                : l10n.all;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Material(
                  color: isSelected ? color : color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelect(type),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 15,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : color,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Report Card
// ─────────────────────────────────────────────
class _ReportCard extends StatefulWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final r = widget.report;

    final emp = r['employeeId'] ?? {};
    final type = r['type'] ?? '';
    final photo = r['photo'] as String?;
    final desc = r['description'] ?? '';
    final timeStr = r['createdAt'] != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(
            DateTime.parse(r['createdAt']).add(const Duration(hours: 1)))
        : '';

    final typeColor = _ReportMeta.color(type);
    final typeIcon = _ReportMeta.icon(type);
    final typeLabel = _ReportMeta.label(type, l10n);
    final empName = emp['fullName'] ?? l10n.unknown;
    final empNum = emp['employeeNumber'] ?? '';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: typeColor.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: typeColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo / Header ──
              if (photo != null)
                _CardPhoto(photo: photo, typeColor: typeColor, typeIcon: typeIcon, typeLabel: typeLabel)
              else
                _CardHeaderNoPhoto(typeColor: typeColor, typeIcon: typeIcon, typeLabel: typeLabel),

              // ── Body ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee row
                      Row(
                        children: [
                          _InitialsAvatar(name: empName, color: typeColor, size: 38),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  empName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (empNum.isNotEmpty)
                                  Text(
                                    empNum,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Footer
                      Divider(
                        height: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: typeColor,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 10,
                                  color: typeColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card sub-widgets ──

class _CardPhoto extends StatelessWidget {
  final String photo;
  final Color typeColor;
  final IconData typeIcon;
  final String typeLabel;

  const _CardPhoto({
    required this.photo,
    required this.typeColor,
    required this.typeIcon,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: SizedBox(
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReportPhoto(photo, height: 140, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 12,
              child: _TypePill(
                icon: typeIcon,
                label: typeLabel,
                color: typeColor,
                onDark: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeaderNoPhoto extends StatelessWidget {
  final Color typeColor;
  final IconData typeIcon;
  final String typeLabel;

  const _CardHeaderNoPhoto({
    required this.typeColor,
    required this.typeIcon,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: _TypePill(icon: typeIcon, label: typeLabel, color: typeColor),
    );
  }
}

// ─────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────
class _TypePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool onDark;

  const _TypePill({
    required this.icon,
    required this.label,
    required this.color,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = onDark
        ? Colors.white.withValues(alpha: 0.18)
        : color.withValues(alpha: 0.12);
    final border = onDark
        ? Colors.white.withValues(alpha: 0.3)
        : color.withValues(alpha: 0.25);
    final textColor = onDark ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const _InitialsAvatar({
    required this.name,
    required this.color,
    required this.size,
  });

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NoMatch extends StatelessWidget {
  final AppLocalizations l10n;
  const _NoMatch({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: cs.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noMatchingReports,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tryDifferentSearch,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Detail Screen
// ─────────────────────────────────────────────
class ReportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ApiService _api = ApiService();
  bool _deleting = false;

  Future<void> _deleteReport() async {
    final l10n = AppLocalizations.of(context);
    final reportId = widget.report['id'] ?? widget.report['_id'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteReport),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await _api.delete('/employee-reports/$reportId');
      if (!mounted) return;
      showSuccess(context, l10n.reportDeleted);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final emp = widget.report['employeeId'] ?? {};
    final type = widget.report['type'] ?? '';
    final photo = widget.report['photo'] as String?;
    final desc = widget.report['description'] ?? '';
    final timeStr = widget.report['createdAt'] != null
        ? DateFormat('dd MMM yyyy, HH:mm')
            .format(DateTime.parse(widget.report['createdAt']).add(const Duration(hours: 1)))
        : '';

    final typeColor = _ReportMeta.color(type);
    final typeIcon = _ReportMeta.icon(type);
    final typeLabel = _ReportMeta.label(type, l10n);
    final empName = emp['fullName'] ?? l10n.unknown;
    final empNum = emp['employeeNumber'] ?? '';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Appbar ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: typeColor,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            actions: [
              if (_deleting)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _deleting ? null : _deleteReport,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      typeColor,
                      typeColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(typeIcon, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      typeLabel.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Employee card
                _DetailSection(
                  cs: cs,
                  children: [
                    Row(
                      children: [
                        _InitialsAvatar(name: empName, color: typeColor, size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.employee,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                empName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              if (empNum.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    empNum,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: typeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description card
                _DetailSection(
                  cs: cs,
                  children: [
                    _SectionHeader(
                      icon: Icons.description_outlined,
                      title: l10n.description,
                      color: typeColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      desc,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),

                // Photo card
                if (photo != null) ...[
                  const SizedBox(height: 12),
                  _DetailSection(
                    cs: cs,
                    children: [
                      _SectionHeader(
                        icon: Icons.image_outlined,
                        title: l10n.photo,
                        color: typeColor,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InteractiveViewer(
                          child: ReportPhoto(photo, fit: BoxFit.contain),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final ColorScheme cs;
  final List<Widget> children;

  const _DetailSection({required this.cs, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Pagination Bar
// ─────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.total,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$total ${l10n.total}',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: onPrevious,
                  tooltip: 'Previous',
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  '$page${totalPages > 0 ? ' / $totalPages' : ''}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onNext,
                  tooltip: 'Next',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}