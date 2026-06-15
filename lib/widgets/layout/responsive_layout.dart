import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) return desktop;
        if (constraints.maxWidth >= 600 && tablet != null) return tablet!;
        return mobile;
      },
    );
  }
}

class AdminShell extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final String title;
  final List<Widget>? actions;
  final String? userName;
  final String? userRole;
  final VoidCallback? onLogout;
  final String? logoutTooltip;

  const AdminShell({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.title = 'Dashboard',
    this.actions,
    this.userName,
    this.userRole,
    this.onLogout,
    this.logoutTooltip,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _sidebarCtrl;
  late Animation<double> _sidebarWidth;
  bool _sidebarExpanded = true;
  static const double _sidebarExpandedWidth = 240;
  static const double _sidebarCollapsedWidth = 72;

  @override
  void initState() {
    super.initState();
    _sidebarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sidebarWidth = Tween<double>(
      begin: _sidebarExpandedWidth,
      end: _sidebarCollapsedWidth,
    ).animate(CurvedAnimation(
      parent: _sidebarCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _sidebarCtrl.dispose();
    super.dispose();
  }

  void _onSidebarHover(bool hovering) {
    setState(() {
      if (hovering && !_sidebarExpanded) {
        _sidebarCtrl.reverse();
        _sidebarExpanded = true;
      } else if (!hovering && _sidebarExpanded) {
        _sidebarCtrl.forward();
        _sidebarExpanded = false;
      }
    });
  }

  void _toggleSidebar() {
    if (_sidebarExpanded) {
      _sidebarCtrl.forward();
    } else {
      _sidebarCtrl.reverse();
    }
    _sidebarExpanded = !_sidebarExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileAdminShell(
        title: widget.title,
        destinations: widget.destinations,
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        body: widget.body,
        actions: widget.actions,
        onLogout: widget.onLogout,
        logoutTooltip: widget.logoutTooltip,
      ),
      tablet: _desktopLayout(compact: true),
      desktop: _desktopLayout(compact: false),
    );
  }

  Widget _desktopLayout({required bool compact}) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          if (compact)
            _CompactSidebar(
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: widget.destinations,
            )
          else
            MouseRegion(
              onEnter: (_) => _onSidebarHover(true),
              onExit: (_) => _onSidebarHover(false),
              child: AnimatedBuilder(
                animation: _sidebarWidth,
                builder: (context, child) => _ExpandableSidebar(
                  width: _sidebarWidth.value,
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: (i) {
                    widget.onDestinationSelected(i);
                  },
                  destinations: widget.destinations,
                  expanded: _sidebarExpanded,
                  userName: widget.userName,
                  userRole: widget.userRole,
                  onLogout: widget.onLogout,
                  onToggle: _toggleSidebar,
                ),
              ),
            ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(widget.title),
                actions: [
                  if (widget.actions != null) ...widget.actions!,
                  const GapW(8),
                ],
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: widget.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAdminShell extends StatelessWidget {
  final String title;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onLogout;
  final String? logoutTooltip;

  const _MobileAdminShell({
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.actions,
    this.onLogout,
    this.logoutTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (actions != null) ...actions!,
          if (onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: logoutTooltip ?? 'Logout',
              onPressed: onLogout,
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: body,
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            animationDuration: const Duration(milliseconds: 400),
            destinations: destinations,
            height: 65,
          ),
        ),
      ),
    );
  }
}

class _CompactSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const _CompactSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.deepBlue,
      child: Column(
        children: [
          const GapH(16),
          const Icon(Icons.access_time_rounded, color: AppColors.indigoLight, size: 28),
          const GapH(24),
          ...List.generate(destinations.length, (i) {
            final selected = i == selectedIndex;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Tooltip(
                message: destinations[i].label,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onDestinationSelected(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: selected ? (isDark ? AppColors.darkPrimary : AppColors.indigo) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: selected ? Colors.white : AppColors.darkMuted,
                          size: 22,
                        ),
                        child: selected && destinations[i].selectedIcon != null
                            ? destinations[i].selectedIcon!
                            : destinations[i].icon,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Icon(Icons.logout, color: AppColors.darkMuted, size: 20),
          const GapH(20),
        ],
      ),
    );
  }
}

class _ExpandableSidebar extends StatelessWidget {
  final double width;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final bool expanded;
  final String? userName;
  final String? userRole;
  final VoidCallback? onLogout;
  final VoidCallback onToggle;

  const _ExpandableSidebar({
    required this.width,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.expanded,
    this.userName,
    this.userRole,
    this.onLogout,
    required this.onToggle,
  });

  bool get _showText => width > 100;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      color: isDark ? AppColors.darkSurface : AppColors.deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          SizedBox(
            height: 64,
            child: Row(
              children: [
                const GapW(16),
                SizedBox(
                  width: 36,
                  child: Icon(Icons.access_time_rounded, color: AppColors.indigoLight, size: 28),
                ),
                if (_showText) ...[
                  const GapW(10),
                  Text('LORIS',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: AppColors.darkBorder, height: 1),
          const GapH(12),
          // Nav items
          ...List.generate(destinations.length, (i) {
            final selected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onDestinationSelected(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? (isDark ? AppColors.darkPrimary : AppColors.indigo) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconTheme(
                          data: IconThemeData(
                            color: selected ? Colors.white : AppColors.darkMuted,
                            size: 20,
                          ),
                          child: selected && destinations[i].selectedIcon != null
                              ? destinations[i].selectedIcon!
                              : destinations[i].icon,
                        ),
                        if (_showText) ...[
                          const GapW(12),
                          Text(destinations[i].label,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? Colors.white : AppColors.darkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Collapse toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        expanded ? Icons.chevron_left : Icons.chevron_right,
                        color: AppColors.darkMuted, size: 20,
                      ),
                      if (_showText) ...[
                        const GapW(12),
                        Text(expanded ? 'Collapse' : 'Expand',
                          style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.darkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // User profile
          const Divider(color: AppColors.darkBorder, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.indigo,
                  child: Text(
                    (userName ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_showText) ...[
                  const GapW(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName ?? 'Admin',
                          style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(userRole ?? 'Administrator',
                          style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.darkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onLogout != null)
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout, size: 18, color: AppColors.darkMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
