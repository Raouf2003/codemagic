import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../widgets/common/language_button.dart';
import '../../l10n/l10n.dart';
import '../login_screen.dart';
import 'manage_employees_screen.dart';
import 'qr_display_screen.dart';
import 'manual_attendance_dialog.dart';
import 'reports_screen.dart';
import 'employee_reports_screen.dart';
import 'settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  List<NavigationDestination> _buildDestinations(AppLocalizations l10n) => [
    NavigationDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard),
      label: l10n.dashboard,
    ),
    NavigationDestination(
      icon: const Icon(Icons.people_outline),
      selectedIcon: const Icon(Icons.people),
      label: l10n.employees,
    ),
    NavigationDestination(
      icon: const Icon(Icons.bar_chart_outlined),
      selectedIcon: const Icon(Icons.bar_chart),
      label: l10n.reports,
    ),
    NavigationDestination(
      icon: const Icon(Icons.feedback_outlined),
      selectedIcon: const Icon(Icons.feedback),
      label: l10n.employeeReports,
    ),
    NavigationDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      label: l10n.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return AdminShell(
      title: _getTitle(l10n),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      destinations: _buildDestinations(l10n),
      userName: auth.employee?.fullName ?? l10n.admin,
      userRole: l10n.administrator,
      onLogout: _logout,
      logoutTooltip: l10n.logout,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _buildBody(auth, l10n),
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (_, tp, __) => IconButton(
            icon: Icon(tp.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: tp.toggleTheme,
            tooltip: l10n.toggleTheme,
          ),
        ),
        const LanguageButton(),
      ],
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 0: return l10n.dashboard;
      case 1: return l10n.manageEmployees;
      case 2: return l10n.reports;
      case 3: return l10n.employeeReports;
      case 4: return l10n.settings;
      default: return l10n.adminPanel;
    }
  }

  Widget _buildBody(AuthProvider auth, AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 0: return _DashboardView(key: const ValueKey('dashboard'), auth: auth, l10n: l10n, onNavigate: (i) => setState(() => _selectedIndex = i));
      case 1: return const ManageEmployeesScreen(key: ValueKey('employees'));
      case 2: return const ReportsScreen(key: ValueKey('reports'));
      case 3: return const EmployeeReportsScreen(key: ValueKey('empReports'));
      case 4: return const SettingsScreen(key: ValueKey('settings'));
      default: return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.logout,
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.logoutConfirm,
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.textMuted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                l10n.cancel,
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                l10n.logout,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard View
// ─────────────────────────────────────────────

class _DashboardView extends StatefulWidget {
  final AuthProvider auth;
  final AppLocalizations l10n;
  final ValueChanged<int>? onNavigate;

  const _DashboardView({super.key, required this.auth, required this.l10n, this.onNavigate});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  int _totalEmployees = 0;
  int _workingNow = 0;
  late Timer _timer;
  late AnimationController _staggerCtrl;
  late Animation<double> _kpiAnim;
  late Animation<double> _actionsAnim;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _kpiAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    _actionsAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _loadWorkingNow());
  }

  @override
  void dispose() {
    _timer.cancel();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWorkingNow() async {
    try {
      final liveResp = await _api.get('/admin/live-employees');
      if (mounted && liveResp['working'] != null) {
        setState(() => _workingNow = (liveResp['working'] as List).length);
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    _staggerCtrl.forward();
    final results = await Future.wait([
      _api.get('/admin/live-employees').catchError((_) => <String, dynamic>{}),
      _api.get('/employees').catchError((_) => <String, dynamic>{}),
    ]);
    if (!mounted) return;
    final liveResp = results[0];
    final empResp = results[1];
    if (liveResp['working'] != null) {
      _workingNow = (liveResp['working'] as List).length;
    }
    if (empResp['employees'] != null) {
      _totalEmployees = ((empResp['employees'] as List).length - 1).clamp(0, 999999);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) greeting = widget.l10n.goodMorning;
    else if (hour < 17) greeting = widget.l10n.goodAfternoon;
    else greeting = widget.l10n.goodEvening;

    final firstName = widget.auth.employee?.fullName.split(' ').first
        ?? widget.l10n.admin;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 900;
        final pad = isWide ? 48.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
          child: isWide
              ? Center(
                  child: SizedBox(
                    width: 1000,
                    child: _dashboardContent(greeting, firstName, isDark, isWide),
                  ),
                )
              : _dashboardContent(greeting, firstName, isDark, isWide),
        );
      },
    );
  }

  Widget _dashboardContent(String greeting, String firstName, bool isDark, [bool isWide = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero greeting banner ──────────────────────────
        _GreetingBanner(
          greeting: greeting,
          firstName: firstName,
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        // ── KPI Cards ─────────────────────────────────────
        FadeTransition(
          opacity: _kpiAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(_kpiAnim),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_rounded,
                    value: '$_totalEmployees',
                    label: widget.l10n.totalEmployees,
                    accentColor: AppColors.indigo,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.work_history_rounded,
                    value: '$_workingNow',
                    label: widget.l10n.workingNow,
                    accentColor: AppColors.emerald,
                    isDark: isDark,
                    showLiveDot: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Section header ────────────────────────────────
        FadeTransition(
          opacity: _actionsAnim,
          child: _SectionLabel(label: widget.l10n.quickActions, isDark: isDark),
        ),
        const SizedBox(height: 12),

        // ── Action grid ───────────────────────────────────
        FadeTransition(
          opacity: _actionsAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(_actionsAnim),
            child: GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: isWide ? 16 : 12,
              mainAxisSpacing: isWide ? 16 : 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isWide ? 1.5: 1.18,
              children: [
                _ActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.indigo,
                  title: widget.l10n.qrCheckin,
                  subtitle: widget.l10n.displayQR,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrDisplayScreen()),
                  ),
                ),
                _ActionCard(
                  icon: Icons.people_rounded,
                  color: AppColors.emerald,
                  title: widget.l10n.employees,
                  subtitle: widget.l10n.manageStaff,
                  isDark: isDark,
                  onTap: () => widget.onNavigate?.call(1),
                ),
                _ActionCard(
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFFF59E0B),
                  title: widget.l10n.reports,
                  subtitle: widget.l10n.viewAttendance,
                  isDark: isDark,
                  onTap: () => widget.onNavigate?.call(2),
                ),
                _ActionCard(
                  icon: Icons.feedback_rounded,
                  color: const Color(0xFF3B82F6),
                  title: widget.l10n.feedback,
                  subtitle: widget.l10n.employeeReports,
                  isDark: isDark,
                  onTap: () => widget.onNavigate?.call(3),
                ),
                _ActionCard(
                  icon: Icons.edit_calendar_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: widget.l10n.manualAttendance,
                  subtitle: widget.l10n.date,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const ManualAttendancePage(),
                    ),
                  ).then((result) {
                    if (result == true) _loadWorkingNow();
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Greeting Banner
// ─────────────────────────────────────────────

class _GreetingBanner extends StatelessWidget {
  final String greeting;
  final String firstName;
  final bool isDark;

  const _GreetingBanner({
    required this.greeting,
    required this.firstName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.indigo.withValues(alpha: 0.25)
              : AppColors.indigo.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName 👋',
                  style: AppTypography.h3.copyWith(
                    color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.indigo.withValues(alpha: 0.7)
                        : const Color(0xFF6366F1).withValues(alpha: 0.75),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.indigo.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: isDark ? const Color(0xFFA5B4FC) : AppColors.indigo,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stat Card (replaces KpiCard for dashboard)
// ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;
  final bool isDark;
  final bool showLiveDot;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    required this.isDark,
    this.showLiveDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              if (showLiveDot) _LiveBadge(color: accentColor),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: isDark ? AppColors.darkText : AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Live Pulse Badge
// ─────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  final Color color;
  const _LiveBadge({required this.color});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: _pulse.value),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _pulse.value * 0.5),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          AppLocalizations.of(context).live,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: widget.color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.indigo,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.h3.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Action Card
// ─────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _hoverCtrl.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _hoverCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _hoverCtrl.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.color.withValues(alpha: _pressed ? 0.35 : 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(
                  alpha: widget.isDark ? (_pressed ? 0.18 : 0.1) : (_pressed ? 0.14 : 0.06),
                ),
                blurRadius: _pressed ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 19),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: (widget.isDark ? AppColors.darkMuted : AppColors.textMuted)
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? AppColors.darkText : AppColors.textDark,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: widget.isDark ? AppColors.darkMuted : AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}