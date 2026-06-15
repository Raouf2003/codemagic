import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../models/attendance.dart';
import '../models/attendance_record.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/employee_report_provider.dart';

import '../widgets/common/app_snackbar.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/language_button.dart';
import '../widgets/common/report_photo.dart';
import '../widgets/skeletons/skeleton_widget.dart';
import '../providers/theme_provider.dart';
import '../l10n/l10n.dart';
import 'employee/checkin_scan_screen.dart';
import 'employee/face_verification_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [l10n.attendance, l10n.history, l10n.reports];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          const LanguageButton(),
          Consumer<ThemeProvider>(
            builder: (_, tp, __) => IconButton(
              icon: Icon(tp.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: tp.toggleTheme,
              tooltip: l10n.toggleTheme,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: [
          _AttendanceTab(),
          _HistoryTab(),
          _ReportsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          _pageController.animateToPage(i,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic);
        },
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        animationDuration: const Duration(milliseconds: 400),
        destinations: [
          NavigationDestination(
            icon: _NavIcon(icon: Icons.access_time, selected: _selectedIndex == 0),
            selectedIcon: const Icon(Icons.access_time_filled),
            label: l10n.attendance,
          ),
          NavigationDestination(
            icon: _NavIcon(icon: Icons.history, selected: _selectedIndex == 1),
            selectedIcon: const Icon(Icons.history),
            label: l10n.history,
          ),
          NavigationDestination(
            icon: _NavIcon(icon: Icons.description_outlined, selected: _selectedIndex == 2),
            selectedIcon: const Icon(Icons.description),
            label: l10n.reports,
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              Text(l10n.logout, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(l10n.logoutConfirm, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(l10n.cancel, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(l10n.logout, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    _isLoggingOut = true;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, _, _) => const LoginScreen(),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  const _NavIcon({required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Icon(icon),
    );
  }
}

/* ───────── Tab 1: Attendance ───────── */

class _AttendanceTab extends StatefulWidget {
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  bool _isProcessing = false;

  Future<bool> _checkConnectivity() async {
    final l10n = AppLocalizations.of(context);
    final results = await Connectivity().checkConnectivity();
    final hasInternet = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
    if (!hasInternet) {
      showError(context, l10n.checkinNoInternet);
      return false;
    }
    return true;
  }

  Future<void> _handleCheckIn(String period) async {
    if (_isProcessing) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<AttendanceProvider>();

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    if (period == 'morning') {
      final parts = provider.morningStart.split(':');
      final startMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final endParts = provider.morningEnd.split(':');
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      if (nowMin < startMin || nowMin >= endMin) {
        showError(context, '${l10n.morningCheckinTime} ${provider.morningStart} - ${provider.morningEnd}');
        return;
      }
    }
    if (period == 'evening') {
      final parts = provider.eveningStart.split(':');
      final startMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final endParts = provider.eveningEnd.split(':');
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      if (nowMin < startMin || nowMin >= endMin) {
        showError(context, '${l10n.eveningCheckinTime} ${provider.eveningStart} - ${provider.eveningEnd}');
        return;
      }
    }

    _isProcessing = true;

    if (!await _checkConnectivity()) { _isProcessing = false; return; }
    if (!mounted) return;

    final geoError = await provider.checkGeofence();
    if (!mounted) return;
    if (geoError != null) {
      showError(context, geoError);
      _isProcessing = false;
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckinScanScreen(
          period: period,
          lat: provider.currentLat,
          lng: provider.currentLng,
        ),
      ),
    );
    if (mounted) {
      if (result == true) {
        await context.read<AttendanceProvider>().loadStatus();
      }
      _isProcessing = false;
    }
  }

  Future<void> _handleCheckOut(String period) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final l10n = AppLocalizations.of(context);

    if (!await _checkConnectivity()) { _isProcessing = false; return; }
    if (!mounted) return;

    final faceVerified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FaceVerificationScreen(
          period: period,
          mode: 'checkout',
        ),
      ),
    );

    if (!mounted) return;

    if (faceVerified != true) {
      _isProcessing = false;
      return;
    }

    final provider = context.read<AttendanceProvider>();
    final error = await provider.checkOut(period);
    if (!mounted) return;
    if (error != null) {
      showError(context, error == 'no_internet' ? l10n.checkoutNoInternet : error);
    } else {
      showSuccess(context, period == 'morning' ? l10n.morningCheckOutSuccess : l10n.eveningCheckOutSuccess);
    }
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => attendance.loadStatus(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(auth, l10n, colorScheme, attendance),
            const SizedBox(height: 16),
            if (attendance.isLoading)
              ...List.generate(2, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12), child: SkeletonPeriodCard(),
              ))
            else ...[
              _buildPeriodCard(
                label: l10n.morning, timeRange: attendance.morningTimeRange,
                status: attendance.morningStatus, attendance: attendance.morningAttendance,
                icon: Icons.wb_sunny, color: Colors.orange, colorScheme: colorScheme, l10n: l10n,
                isLoading: _isProcessing,
                period: 'morning',
                onAction: () {
                  if (attendance.morningStatus == 'not_started') { _handleCheckIn('morning'); }
                  else if (attendance.morningStatus == 'working') { _handleCheckOut('morning'); }
                },
              ),
              const SizedBox(height: 12),
              _buildPeriodCard(
                label: l10n.evening, timeRange: attendance.eveningTimeRange,
                status: attendance.eveningStatus, attendance: attendance.eveningAttendance,
                icon: Icons.nights_stay, color: Colors.indigo, colorScheme: colorScheme, l10n: l10n,
                isLoading: _isProcessing,
                period: 'evening',
                onAction: () {
                  if (attendance.eveningStatus == 'not_started') { _handleCheckIn('evening'); }
                  else if (attendance.eveningStatus == 'working') { _handleCheckOut('evening'); }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider auth, AppLocalizations l10n, ColorScheme colorScheme, AttendanceProvider attendance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: colorScheme.primaryContainer, child: Icon(Icons.person, size: 30, color: colorScheme.onPrimaryContainer)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(auth.employee?.fullName ?? l10n.employeeFallback, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text('${l10n.employeeId}: ${auth.employee?.employeeNumber ?? ''}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ])),
              ],
            ),
            if (attendance.isAnyWorking) ...[
              const SizedBox(height: 12),
              if (attendance.connectionLost)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.connectionLost}. ${l10n.autoCheckoutWarning}',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: attendance.isInsideGeofence
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: attendance.isInsideGeofence
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.red.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      attendance.isInsideGeofence ? Icons.location_on : Icons.location_off,
                      size: 16,
                      color: attendance.isInsideGeofence ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      attendance.isInsideGeofence ? l10n.insideAllowedArea : l10n.outsideAllowedArea,
                      style: TextStyle(
                        fontSize: 12,
                        color: attendance.isInsideGeofence ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodCard({
    required String label, required String timeRange, required String status,
    required Attendance? attendance, required IconData icon, required Color color,
    required ColorScheme colorScheme, required AppLocalizations l10n,
    required VoidCallback onAction, bool isLoading = false, String period = 'morning',
  }) {
    Color statusColor; String statusText; IconData statusIcon;
    switch (status) {
      case 'working': statusColor = Colors.green; statusText = l10n.working; statusIcon = Icons.work; break;
      case 'finished': statusColor = Colors.blue; statusText = l10n.finished; statusIcon = Icons.check_circle; break;
      default: statusColor = Colors.grey; statusText = l10n.notStarted; statusIcon = Icons.schedule;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 24), const SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusIcon, size: 14, color: statusColor), const SizedBox(width: 4),
                  Text(statusText, style: TextStyle(fontSize: 12, color: statusColor)),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            Text(timeRange, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
            if (status == 'working') ...[
              const SizedBox(height: 10),
              _WorkingTimer(period: period),
            ],
            if (status == 'finished' && attendance != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${l10n.total}: ${attendance.totalMinutes ~/ 60}h ${attendance.totalMinutes % 60}m', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  if (attendance.checkoutType == 'auto') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_mode, size: 12, color: Colors.orange),
                          const SizedBox(width: 3),
                          Text(l10n.auto, style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (status == 'not_started')
              SizedBox(width: double.infinity, child: FilledButton.tonalIcon(onPressed: isLoading ? null : onAction, icon: const Icon(Icons.login, size: 18), label: Flexible(child: Text(l10n.checkIn, overflow: TextOverflow.ellipsis))))
            else if (status == 'working')
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: isLoading ? null : onAction, icon: const Icon(Icons.logout, size: 18), label: Flexible(child: Text(l10n.checkOut, overflow: TextOverflow.ellipsis)),
                style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              )),
          ],
        ),
      ),
    );
  }
}

class _WorkingTimer extends StatefulWidget {
  final String period;
  const _WorkingTimer({required this.period});

  @override
  State<_WorkingTimer> createState() => _WorkingTimerState();
}

class _WorkingTimerState extends State<_WorkingTimer> {
  Duration _displayElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _displayElapsed = context.read<AttendanceProvider>().elapsed;
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _displayElapsed = context.read<AttendanceProvider>().elapsed;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final h = _displayElapsed.inHours.toString().padLeft(2, '0');
    final m = (_displayElapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_displayElapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Row(children: [
      Icon(Icons.work_history, size: 14, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 4),
      Text(l10n.workingLabel, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      Text('$h:$m:$s', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Theme.of(context).colorScheme.primary)),
    ]);
  }
}

  /* ───────── Tab 2: History ───────── */

class _HistoryTab extends StatefulWidget {
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeReportProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<EmployeeReportProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildMonthPicker(provider, colorScheme),
        if (provider.summary != null) _buildSummary(provider.summary!, l10n, colorScheme),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadHistory(),
            child: provider.isLoadingHistory
            ? const SkeletonList(itemCount: 4)
            : provider.records.isEmpty
              ? ListView(
                  children: [EmptyState(icon: Icons.event_busy, title: l10n.noRecords, subtitle: l10n.noRecordsSubtitle)],
                )
              : _buildGroupedHistory(provider, l10n, colorScheme),
            ),
          ),
        ],
      );
  }

  Widget _buildMonthPicker(EmployeeReportProvider provider, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () { int m = provider.selectedMonth - 1; int y = provider.selectedYear; if (m == 0) { m = 12; y--; } if (y < 2024 || (y == 2024 && m < 1)) return; provider.loadHistory(month: m, year: y); }),
        Expanded(child: Text('${_monthName(provider.selectedMonth.toString().padLeft(2, '0'))} ${provider.selectedYear}', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { int m = provider.selectedMonth + 1; int y = provider.selectedYear; if (m == 13) { m = 1; y++; } final now = DateTime.now(); if (y > now.year || (y == now.year && m > now.month)) return; provider.loadHistory(month: m, year: y); }),
      ]),
    );
  }

  Widget _buildSummary(Map<String, dynamic> summary, AppLocalizations l10n, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _summaryItem(l10n.days, '${summary['totalDays'] ?? 0}', Colors.green),
        _summaryItem(l10n.hours, '${summary['totalHours'] ?? '0h 0m'}', colorScheme.primary),
      ]))),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(children: [Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 12))]);
  }

  String _monthName(String m) { final l10n = AppLocalizations.of(context); final names = ['', l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.may, l10n.jun, l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec]; final idx = int.parse(m); return idx >= 1 && idx <= 12 ? names[idx] : m; }

  Widget _buildGroupedHistory(EmployeeReportProvider provider, AppLocalizations l10n, ColorScheme colorScheme) {
    final grouped = <String, List<AttendanceRecord>>{};
    for (final r in provider.records) {
      grouped.putIfAbsent(r.date, () => []).add(r);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dates.length,
      itemBuilder: (ctx, i) {
        final date = dates[i];
        final records = grouped[date]!;
        final morning = records.where((r) => r.period == 'morning').firstOrNull;
        final evening = records.where((r) => r.period == 'evening').firstOrNull;
        final day = int.parse(date.substring(8));
        final month = date.substring(5, 7);

        int totalDayMin = 0;
        for (final r in records) totalDayMin += r.totalMinutes;
        final totalH = totalDayMin ~/ 60;
        final totalM = totalDayMin % 60;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Text(day.toString().padLeft(2, '0'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  Text(_monthName(month), style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      if (morning != null) _buildPeriodRow(morning, l10n.am, Colors.orange, colorScheme, l10n),
                      if (morning != null && evening != null) const SizedBox(height: 8),
                      if (evening != null) _buildPeriodRow(evening, l10n.pm, Colors.indigo, colorScheme, l10n),
                    ],
                  ),
                ),
                if (totalDayMin > 0)
                  Text('${totalH}h ${totalM}m', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodRow(AttendanceRecord r, String label, Color color, ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(fontSize: 11, color: color)),
        ),
        if (r.autoCheckout) ...[const SizedBox(width: 6), Icon(Icons.auto_mode, size: 14, color: Colors.orange)],
        const SizedBox(width: 8),
        Text('${l10n.inLabel}: ${r.checkInStr}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Text('${l10n.outLabel}: ${r.checkOutStr}', style: TextStyle(fontSize: 13, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/* ───────── Tab 3: Reports ───────── */

class _ReportsTab extends StatefulWidget {
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeReportProvider>().loadReports();
    });
  }

  IconData _typeIcon(String type) { switch (type) { case 'issue': return Icons.report_problem; case 'inventory': return Icons.inventory_2; case 'feedback': return Icons.feedback; default: return Icons.description; } }
  Color _typeColor(String type) { switch (type) { case 'issue': return Colors.red; case 'inventory': return Colors.blue; case 'feedback': return Colors.green; default: return Colors.grey; } }

  void _openCreateReport() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _CreateReportPage()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<EmployeeReportProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.loadReports(),
        child: provider.isLoadingReports
          ? const SkeletonList()
          : provider.reports.isEmpty
            ? EmptyState(icon: Icons.description_outlined, title: l10n.noReports, subtitle: l10n.noReportsSubtitle)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: provider.reports.length,
                itemBuilder: (ctx, i) {
                  final r = provider.reports[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _typeColor(r.type).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_typeIcon(r.type), color: _typeColor(r.type), size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.typeLabel, style: TextStyle(fontWeight: FontWeight.bold, color: _typeColor(r.type), fontSize: 13)),
                            Text(r.formattedDate, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                          ])),
                        ]),
                        const SizedBox(height: 8),
                        Text(r.description, style: TextStyle(color: colorScheme.onSurface, fontSize: 14)),
                        if (r.photo != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: ReportPhoto(r.photo!, height: 120)),
                        ],
                      ]),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateReport,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/* ───────── Create Report (inline page) ───────── */

class _CreateReportPage extends StatefulWidget {
  const _CreateReportPage();
  @override
  State<_CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<_CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String _selectedType = 'issue';
  Uint8List? _imageBytes;
  String? _imageBase64;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> get _types {
    final l10n = AppLocalizations.of(context);
    return [
      {'value': 'issue', 'label': l10n.issue, 'icon': Icons.report_problem, 'color': Colors.red},
      {'value': 'inventory', 'label': l10n.inventory, 'icon': Icons.inventory_2, 'color': Colors.blue},
      {'value': 'feedback', 'label': l10n.feedback, 'icon': Icons.feedback, 'color': Colors.green},
    ];
  }

  @override
  void dispose() { _descController.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;
      final resized = img.copyResize(decoded, width: 800);
      final compressed = img.encodeJpg(resized, quality: 60);
      setState(() { _imageBytes = compressed; _imageBase64 = base64Encode(compressed); });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      showError(context, l10n.cameraErrorMessageText('$e'));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final provider = context.read<EmployeeReportProvider>();
    final photoToSend = _imageBase64 != null ? 'data:image/jpeg;base64,$_imageBase64' : null;
    final l10n = AppLocalizations.of(context);
    final error = await provider.createReport(_selectedType, _descController.text.trim(), photo: photoToSend);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) { showError(context, error); } else { showSuccess(context, l10n.submitted); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.reportType, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            ..._types.map((t) {
              final val = t['value'] as String;
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  leading: Icon(t['icon'] as IconData, color: t['color'] as Color),
                  title: Text(t['label'] as String),
                  trailing: Icon(Icons.circle, size: 18, color: _selectedType == val ? t['color'] as Color : Colors.transparent),
                  onTap: () => setState(() => _selectedType = val),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                ),
              );
            }),
            const SizedBox(height: 16),
            TextFormField(controller: _descController, decoration: InputDecoration(labelText: l10n.description, alignLabelWithHint: true), maxLines: 5, validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null),
            const SizedBox(height: 16),
            Row(children: [
              FilledButton.tonalIcon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt, size: 18), label: Text(l10n.addPhoto)),
              if (_imageBytes != null) ...[const SizedBox(width: 12), ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(_imageBytes!, width: 60, height: 60, fit: BoxFit.cover)), const SizedBox(width: 8), IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() { _imageBytes = null; _imageBase64 = null; }))],
            ]),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: _isSubmitting ? null : _submit, child: _isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.submitReport))),
          ]),
        ),
      ),
    );
  }
}
