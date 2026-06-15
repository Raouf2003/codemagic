import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../../providers/employee_report_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/report_photo.dart';
import '../../widgets/skeletons/skeleton_widget.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeReportProvider>().loadReports();
    });
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'issue': return Icons.report_problem;
      case 'inventory': return Icons.inventory_2;
      case 'feedback': return Icons.feedback;
      default: return Icons.description;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'issue': return Colors.red;
      case 'inventory': return Colors.blue;
      case 'feedback': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<EmployeeReportProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myReports)),
      body: RefreshIndicator(
        onRefresh: () => provider.loadReports(),
        child: provider.isLoadingReports
            ? const SkeletonList()
            : provider.reports.isEmpty
                ? EmptyState(
                    icon: Icons.description_outlined,
                    title: l10n.noReports,
                    subtitle: l10n.submitFirstReport)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.reports.length,
                    itemBuilder: (ctx, i) {
                      final r = provider.reports[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _typeColor(r.type).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _typeIcon(r.type),
                                      color: _typeColor(r.type),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.typeLabel,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _typeColor(r.type),
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          r.formattedDate,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                r.description,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                              ),
                              if (r.photo != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ReportPhoto(r.photo!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
