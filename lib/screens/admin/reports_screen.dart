import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../../services/api_service.dart';
import '../../services/file_helper.dart';
import '../../services/realtime_service.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/skeletons/skeleton_widget.dart';
import '../../l10n/l10n.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _api = ApiService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String _reportType = 'daily';
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  dynamic _reportData;
  bool _isLoading = false;
  bool _isExporting = false;
  bool _loadingReport = false;
  bool _pendingUpdate = false;
  bool _forceRefresh = false;

  List<Map<String, dynamic>> _allEmployees = [];

  StreamSubscription<Map<String, dynamic>>? _attSub;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadReport();
    _loadEmployees();
    _initRealtime();
    _attSub = RealtimeService().onAttendanceUpdated.listen((_) => _requestRefresh());
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _requestRefresh();
    });
  }

  Future<void> _initRealtime() async {
    final rt = RealtimeService();
    if (!rt.isConnected) {
      final token = await _api.getToken();
      if (token != null) rt.connect(token);
    }
  }

  @override
  void dispose() {
    _attSub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final response = await _api.get('/employees');
      final list = (response['employees'] as List?)
              ?.where((e) => e['role'] != 'admin')
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];
      if (!mounted) return;
      setState(() => _allEmployees = list);
    } catch (_) {
      if (mounted) setState(() => _allEmployees = []);
    }
  }

  void _requestRefresh() {
    _initRealtime();
    if (_loadingReport) {
      _pendingUpdate = true;
      return;
    }
    _loadReport(silent: true);
  }

  Future<void> _loadReport({bool silent = false}) async {
    if (!mounted) return;
    if (_loadingReport && !_forceRefresh) return;
    _forceRefresh = false;
    _loadingReport = true;
    if (!silent) setState(() => _isLoading = true);

    try {
      List report;
      if (_reportType == 'daily') {
        final dateStr = _dateFormat.format(_selectedDate);
        final response = await _api.get('/reports/daily?date=$dateStr');
        report = (response['report'] as List?) ?? [];
      } else {
        final response = await _api.get(
          '/reports/monthly?year=$_selectedYear&month=$_selectedMonth',
        );
        report = (response['report'] as List?) ?? [];
      }
      if (!mounted) return;
      _loadingReport = false;
      if (_pendingUpdate) {
        _pendingUpdate = false;
        _loadReport(silent: true);
        return;
      }
      setState(() {
        _reportData = {'report': report};
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      _loadingReport = false;
      if (_pendingUpdate) {
        _pendingUpdate = false;
        _loadReport(silent: true);
        return;
      }
      setState(() {
        _reportData = {'report': <dynamic>[]};
        _isLoading = false;
      });
    }
  }

  List _getReportList() =>
      (_reportData?['report'] as List?) ?? [];

  List _getEmployeeReportList(Map<String, dynamic> emp) {
    final report = _getReportList();
    final empNum = emp['employeeNumber'];
    return report.where((r) => r['employeeNumber'] == empNum).toList();
  }

  String _getFilename(String ext) {
    if (_reportType == 'daily') {
      return 'attendance_${_dateFormat.format(_selectedDate)}.$ext';
    }
    final m = _selectedMonth.toString().padLeft(2, '0');
    return 'attendance_${_selectedYear}_$m.$ext';
  }

  String _getEmployeeFilename(Map<String, dynamic> emp, String ext) {
    return '${emp['employeeNumber']}_attendance.$ext';
  }

  String _formatMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  String _formatTimeHm(String? timeStr) {
    if (timeStr == null) return '-';
    try {
      final dt = DateTime.parse(timeStr);
      final algeria = dt.add(const Duration(hours: 1));
      return DateFormat('HH:mm').format(algeria);
    } catch (_) {
      return '-';
    }
  }

  // --- Export All ---

  Future<void> _exportAll(String format) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isExporting = true);
    try {
      final filename = _getFilename(format == 'pdf' ? 'pdf' : 'xlsx');
      final bytes = _reportType == 'daily'
          ? (format == 'pdf'
              ? await _generateDailyPdf(_getReportList())
              : await _generateDailyExcel(_getReportList()))
          : (format == 'pdf'
              ? await _generateMonthlyPdf(_getReportList())
              : await _generateMonthlyExcel(_getReportList()));
      downloadFile(filename, bytes);
      if (mounted) {
        showSuccess(context, l10n.success);
      }
    } catch (e) {
      if (mounted) {
        showError(context, l10n.downloadFailed);
      }
    }
    setState(() => _isExporting = false);
  }

  Future<void> _exportEmployee(String format, Map<String, dynamic> emp) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isExporting = true);
    try {
      final data = _getEmployeeReportList(emp);
      final filename = _getEmployeeFilename(emp, format == 'pdf' ? 'pdf' : 'xlsx');
      final bytes = _reportType == 'daily'
          ? (format == 'pdf'
              ? await _generateDailyPdf(data)
              : await _generateDailyExcel(data))
          : (format == 'pdf'
              ? await _generateMonthlyPdf(data)
              : await _generateMonthlyExcel(data));
      downloadFile(filename, bytes);
      if (mounted) {
        showSuccess(context, l10n.success);
      }
    } catch (e) {
      if (mounted) {
        showError(context, l10n.downloadFailed);
      }
    }
    setState(() => _isExporting = false);
  }

  // --- PDF Generation ---

  Future<List<int>> _generateDailyPdf(List report) async {
    final l10n = AppLocalizations.of(context);
    final grouped = _groupDailyReport(report);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(l10n.dailyAttendanceReport,
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('${l10n.date} ${_dateFormat.format(_selectedDate)}'),
          pw.SizedBox(height: 4),
          pw.Text('${l10n.totalEmployees}: ${grouped.length}'),
          pw.SizedBox(height: 16),
          if (grouped.isEmpty)
            pw.Text(l10n.noData)
          else
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: pw.FixedColumnWidth(55),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(50),
                3: pw.FixedColumnWidth(50),
                4: pw.FixedColumnWidth(50),
                5: pw.FixedColumnWidth(50),
                6: pw.FixedColumnWidth(55),
               },
               children: [
                 _pdfHeaderRow([
                    l10n.employeeHash, l10n.employee, '${l10n.am} ${l10n.inLabel}', '${l10n.am} ${l10n.outLabel}', '${l10n.pm} ${l10n.inLabel}', '${l10n.pm} ${l10n.outLabel}', l10n.totalTime
                  ]),
                 ...grouped.map((g) {
                   final morning = g['morning'] as Map<String, dynamic>?;
                   final evening = g['evening'] as Map<String, dynamic>?;
                   return pw.TableRow(children: [
                     _pdfCell(g['employeeNumber'] ?? ''),
                     _pdfCell(g['employeeName'] ?? ''),
                     _pdfCell(morning != null ? _formatTimeHm(morning['checkInTime']) : '-'),
                     _pdfCell(morning != null ? _formatTimeHm(morning['checkOutTime']) : '-'),
                     _pdfCell(evening != null ? _formatTimeHm(evening['checkInTime']) : '-'),
                     _pdfCell(evening != null ? _formatTimeHm(evening['checkOutTime']) : '-'),
                     _pdfCell(_formatMinutes(g['totalMinutes'] ?? 0)),
                   ]);
                 }),
               ],
            ),
        ],
      ),
    );
    return pdf.save();
  }

  List<Map<String, dynamic>> _groupDailyReport(List report) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final r in report) {
      final key = '${r['employeeNumber']}_${r['date'] ?? r['employeeNumber']}';
      (grouped[key] ??= []).add(r);
    }
    return grouped.entries.map((e) {
      final records = e.value;
      final first = records.first;
      final morning = records.where((r) => r['period'] == 'morning').firstOrNull;
      final evening = records.where((r) => r['period'] == 'evening').firstOrNull;
      int total = 0;
      for (final r in records) total += ((r['normalMinutes'] ?? r['totalMinutes'] ?? 0) as num).toInt();
      return {
        'employeeNumber': first['employeeNumber'] ?? '',
        'employeeName': first['employeeName'] ?? '',
        'morning': morning,
        'evening': evening,
        'totalMinutes': total,
      };
    }).toList();
  }

  Future<List<int>> _generateMonthlyPdf(List report) async {
    final l10n = AppLocalizations.of(context);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(l10n.monthlyAttendanceReport,
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(
            '${l10n.date} ${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth))}',
          ),
          pw.SizedBox(height: 4),
          pw.Text('${l10n.totalEmployees}: ${report.length}'),
          pw.SizedBox(height: 16),
          if (report.isEmpty)
            pw.Text(l10n.noData)
          else
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: pw.FixedColumnWidth(60),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(85),
                3: pw.FixedColumnWidth(80),
              },
              children: [
                _pdfHeaderRow(
                    [l10n.employeeHash, l10n.employee, l10n.daysPresent, l10n.totalTime]),
                ...report.map((r) {
                  final totalMin = r['totalMinutes'] ?? 0;
                  return pw.TableRow(children: [
                    _pdfCell(r['employeeNumber'] ?? ''),
                    _pdfCell(r['employeeName'] ?? ''),
                    _pdfCell('${r['daysPresent'] ?? 0}'),
                    _pdfCell(_formatMinutes(totalMin)),
                  ]);
                }),
              ],
            ),
        ],
      ),
    );
    return pdf.save();
  }

  pw.TableRow _pdfHeaderRow(List<String> headers) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: headers.map((h) => _pdfCell(h, bold: true)).toList(),
    );
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
              bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // --- Excel Generation ---

  Future<List<int>> _generateDailyExcel(List report) async {
    final l10n = AppLocalizations.of(context);
    final grouped = _groupDailyReport(report);
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()!]!;

    final headers = [
      l10n.employeeHash,
      l10n.employee,
      '${l10n.am} ${l10n.inLabel}',
      '${l10n.am} ${l10n.outLabel}',
      '${l10n.pm} ${l10n.inLabel}',
      '${l10n.pm} ${l10n.outLabel}',
      '${l10n.totalTime} (min)',
    ];
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.grey300,
      );
    }
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, [15.0, 30.0, 14.0, 14.0, 14.0, 14.0, 15.0][i]);
    }

    for (var i = 0; i < grouped.length; i++) {
      final g = grouped[i];
      final row = i + 1;
      final morning = g['morning'] as Map<String, dynamic>?;
      final evening = g['evening'] as Map<String, dynamic>?;
      final vals = <dynamic>[
        g['employeeNumber'] ?? '',
        g['employeeName'] ?? '',
        morning != null ? _formatTimeHm(morning['checkInTime']) : '-',
        morning != null ? _formatTimeHm(morning['checkOutTime']) : '-',
        evening != null ? _formatTimeHm(evening['checkInTime']) : '-',
        evening != null ? _formatTimeHm(evening['checkOutTime']) : '-',
        g['totalMinutes'] ?? 0,
      ];
      for (var c = 0; c < vals.length; c++) {
        final cellVal = vals[c];
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
        if (cellVal is int) {
          cell.value = IntCellValue(cellVal);
        } else {
          cell.value = TextCellValue(cellVal.toString());
        }
      }
    }

    return excel.encode() ?? [];
  }

  Future<List<int>> _generateMonthlyExcel(List report) async {
    final l10n = AppLocalizations.of(context);
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()!]!;

    final headers = [
      l10n.employeeHash,
      l10n.employee,
      l10n.daysPresent,
      '${l10n.totalTime} (min)',
    ];
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.grey300,
      );
    }
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, [15.0, 30.0, 15.0, 18.0][i]);
    }

    for (var i = 0; i < report.length; i++) {
      final r = report[i];
      final row = i + 1;
      final totalMin = r['totalMinutes'] ?? 0;
      final vals = <dynamic>[
        '${r['employeeNumber'] ?? ''}',
        '${r['employeeName'] ?? ''}',
        r['daysPresent'] ?? 0,
        totalMin,
      ];
      for (var c = 0; c < vals.length; c++) {
        final cellVal = vals[c];
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
        if (cellVal is int) {
          cell.value = IntCellValue(cellVal);
        } else {
          cell.value = TextCellValue(cellVal.toString());
        }
      }
    }

    return excel.encode() ?? [];
  }

  // --- Download Choice ---

  Future<void> _showDownloadChoice(
      {Map<String, dynamic>? employee}) async {
    final l10n = AppLocalizations.of(context);
    final format = await formatChoiceDialog(
      context,
      title: employee != null
          ? '${l10n.download}: ${employee['fullName']}'
          : l10n.downloadReport,
      message: l10n.chooseFormat,
    );
    if (format == null || _isExporting) return;

    if (employee != null) {
      _exportEmployee(format, employee);
    } else {
      _exportAll(format);
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                              value: 'daily', label: Text(l10n.daily)),
                          ButtonSegment(
                              value: 'monthly',
                              label: Text(l10n.monthly)),
                        ],
                        selected: {_reportType},
                        onSelectionChanged: (v) {
                          setState(() {
                            _reportType = v.first;
                            _forceRefresh = true;
                            _loadReport();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${_reportType == 'daily' ? l10n.date : l10n.period}: ',
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant)),
                      if (_reportType == 'daily')
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(_dateFormat.format(_selectedDate)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                                _forceRefresh = true;
                                _loadReport();
                              });
                            }
                          },
                        )
                      else
                        Row(
                          children: [
                            DropdownButton<int>(
                              value: _selectedMonth,
                              underline: const SizedBox(),
                              items: List.generate(12, (i) {
                                return DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                      DateFormat('MMMM')
                                          .format(DateTime(2024, i + 1)),
                                      style: const TextStyle(fontSize: 14)),
                                );
                              }),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _selectedMonth = v;
                                    _forceRefresh = true;
                                    _loadReport();
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: _selectedYear,
                              underline: const SizedBox(),
                              items: [2024, 2025, 2026].map((y) {
                                return DropdownMenuItem(
                                    value: y,
                                    child: Text('$y',
                                        style: const TextStyle(fontSize: 14)));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _selectedYear = v;
                                    _forceRefresh = true;
                                    _loadReport();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      const Spacer(),
                      if (_reportData != null)
                        IconButton(
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.download),
                          onPressed:
                              _isExporting ? null : () => _showDownloadChoice(),
                          tooltip: l10n.downloadReport,
                        ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.person_search),
                        tooltip: l10n.downloadEmployeeReport,
                        onSelected: (empId) {
                          final emp = _allEmployees.firstWhere(
                            (e) =>
                                (e['id'] ?? e['_id']).toString() == empId,
                            orElse: () => <String, dynamic>{},
                          );
                          if (emp.isNotEmpty) {
                            _showDownloadChoice(employee: emp);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            enabled: false,
                            child: Text(l10n.employeeReports,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ..._allEmployees.map((e) => PopupMenuItem(
                                value: (e['id'] ?? e['_id']).toString(),
                                child: Text(
                                    '${e['fullName']} (${e['employeeNumber']})'),
                              )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const SkeletonList(itemCount: 4, itemHeight: 120)
                : _reportData == null
                    ? EmptyState(
                        icon: Icons.bar_chart,
                        title: l10n.noData,
                        subtitle: l10n.selectDateOrMonth)
                    : _buildReportContent(l10n, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(AppLocalizations l10n, ColorScheme colorScheme) {
    if (_reportType == 'daily') {
      final report = _getReportList();
      if (report.isEmpty) {
        return EmptyState(
          icon: Icons.event_busy,
          title: l10n.noAttendanceRecords,
          subtitle: l10n.noRecordsForDate,
        );
      }
      return _buildDailyGrouped(report, l10n, colorScheme);
    } else {
      final report = _getReportList();
      if (report.isEmpty) {
        return EmptyState(
          icon: Icons.event_busy,
          title: l10n.noDataForMonth,
          subtitle: l10n.noRecordsFoundPeriod,
        );
      }
      report.sort((a, b) {
        final aDays = (a['days'] as List?) ?? [];
        final bDays = (b['days'] as List?) ?? [];
        final aLast = aDays.isEmpty ? '' : (aDays.last['date'] as String? ?? '');
        final bLast = bDays.isEmpty ? '' : (bDays.last['date'] as String? ?? '');
        return bLast.compareTo(aLast);
      });
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: report.length,
        itemBuilder: (ctx, i) {
          final r = report[i];
          final totalMin = r['totalMinutes'] ?? 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['employeeName'] ?? l10n.unknown,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${l10n.employeeHash}: ${r['employeeNumber'] ?? ''}',
                      style:
                          TextStyle(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStat(l10n.daysPresent,
                          '${r['daysPresent'] ?? 0}', Colors.green),
                      const SizedBox(width: 24),
                      _buildStat(
                          l10n.totalTime,
                          _formatMinutes(totalMin),
                          colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDailyGrouped(List report, AppLocalizations l10n, ColorScheme colorScheme) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final r in report) {
      final key = '${r['employeeNumber']}_${r['date'] ?? r['employeeNumber']}';
      (grouped[key] ??= []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final entry = grouped.entries.elementAt(i);
        final records = entry.value;
        final first = records.first;
        final morning = records.where((r) => r['period'] == 'morning').firstOrNull;
        final evening = records.where((r) => r['period'] == 'evening').firstOrNull;

        int totalDayMin = 0;
        for (final r in records) totalDayMin += ((r['normalMinutes'] ?? r['totalMinutes'] ?? 0) as num).toInt();

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        first['employeeName'] ?? l10n.unknown,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text('${totalDayMin ~/ 60}h ${totalDayMin % 60}m',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${l10n.employeeHash}: ${first['employeeNumber'] ?? ''}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                if (morning != null) _buildAdminPeriodRow(morning, l10n, colorScheme),
                if (morning != null && evening != null) const SizedBox(height: 8),
                if (evening != null) _buildAdminPeriodRow(evening, l10n, colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminPeriodRow(Map<String, dynamic> r, AppLocalizations l10n, ColorScheme colorScheme) {
    final checkIn = _formatTimeHm(r['checkInTime']);
    final checkOut = _formatTimeHm(r['checkOutTime']);
    final totalMin = r['normalMinutes'] ?? r['totalMinutes'] ?? 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (r['period'] == 'morning' ? Colors.orange : Colors.indigo).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            r['period'] == 'morning' ? l10n.am : l10n.pm,
            style: TextStyle(fontSize: 11, color: r['period'] == 'morning' ? Colors.orange : Colors.indigo),
          ),
        ),
        if (r['autoCheckout'] == true) ...[
          const SizedBox(width: 6),
          const Icon(Icons.auto_mode, size: 14, color: Colors.orange),
        ],
        const SizedBox(width: 8),
        Text('${l10n.inLabel}: $checkIn', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Text('${l10n.outLabel}: $checkOut', style: TextStyle(fontSize: 13, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(_formatMinutes(totalMin), style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.primary)),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
