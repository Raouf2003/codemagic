import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_report_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/skeletons/skeleton_widget.dart';
import '../../l10n/l10n.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeReportProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeReportProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendanceHistory)),
      body: Column(
        children: [
          _buildMonthPicker(provider, colorScheme),
          if (provider.summary != null) _buildSummary(provider.summary!, colorScheme),
          const Divider(height: 1),
          Expanded(
            child: provider.isLoadingHistory
                ? const SkeletonList(itemCount: 4)
                : provider.records.isEmpty
                    ? EmptyState(
                        icon: Icons.event_busy,
                        title: l10n.noRecords,
                        subtitle: l10n.noRecordsMonth)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.records.length,
                        itemBuilder: (ctx, i) {
                          final r = provider.records[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        r.date.substring(8),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      Text(
                                        _monthName(r.date.substring(5, 7)),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (r.period == 'morning'
                                                        ? Colors.orange
                                                        : Colors.indigo)
                                                    .withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                r.period == 'morning' ? 'AM' : 'PM',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: r.period == 'morning'
                                                      ? Colors.orange
                                                      : Colors.indigo,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (r.autoCheckout)
                                              Icon(Icons.auto_mode,
                                                  size: 14, color: Colors.orange),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${l10n.checkIn}: ${r.checkInStr}  ${l10n.checkOut}: ${r.checkOutStr}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    r.totalStr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(EmployeeReportProvider provider, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              int m = provider.selectedMonth - 1;
              int y = provider.selectedYear;
              if (m == 0) { m = 12; y--; }
              provider.loadHistory(month: m, year: y);
            },
          ),
          Expanded(
            child: Text(
              '${_monthName(provider.selectedMonth.toString().padLeft(2, '0'))} ${provider.selectedYear}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              int m = provider.selectedMonth + 1;
              int y = provider.selectedYear;
              if (m == 13) { m = 1; y++; }
              final now = DateTime.now();
              if (y > now.year || (y == now.year && m > now.month)) return;
              provider.loadHistory(month: m, year: y);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(Map<String, dynamic> summary, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(l10n.days, '${summary['totalDays'] ?? 0}', Colors.green),
              _summaryItem(l10n.hours, '${summary['totalHours'] ?? '0h 0m'}', colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _monthName(String m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final idx = int.parse(m);
    return idx >= 1 && idx <= 12 ? names[idx] : m;
  }
}
